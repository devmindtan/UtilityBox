from pathlib import Path
from docx import Document
import fitz
from transformers import AutoModelForSequenceClassification, AutoTokenizer, logging
import torch
from src.utils import classify_level_use_ai, ocr_preserve_layout
logging.set_verbosity_error()


class OCRProcessor:
    def __init__(self, FOLDER_PATH, MODEL_NAME):
        self.folder_path = Path(FOLDER_PATH)
        self.model_name = MODEL_NAME
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        self.model = AutoModelForSequenceClassification.from_pretrained(
            MODEL_NAME)

    def extract_text_from_images_in_docx(self):
        data = []
        for doc_file in self.folder_path.glob("*.docx"):
            doc = Document(doc_file)
            rels = doc.part.rels
            all_text_image = []

            all_text = [p.text.strip()
                        for p in doc.paragraphs if p.text.strip()]

            for rel in rels.values():
                if "image" in rel.target_ref:
                    try:
                        img_data = rel.target_part.blob

                        # OCR ảnh (tự động nhận tiếng Anh + Việt)
                        text = ocr_preserve_layout(
                            img_data, lang="eng+vie", psm=6)

                        all_text_image.append(text)
                    except Exception as e:
                        print(f"Lỗi đọc ảnh: {e}")
                        continue
            text_output = "\n".join(all_text)

            data.append({
                "file_name": doc_file.stem.strip(),
                "text_image":  "\n\n".join(all_text_image),
                "text": text_output
            })

        return data

    def extract_text_from_images_in_pdf(self):
        data = []
        for pdf_file in self.folder_path.glob("*.pdf"):
            pdf = fitz.open(pdf_file)
            all_text_image = []
            all_text = []

            for page_num, page in enumerate(pdf, start=1):
                # Lấy text gốc của trang
                all_text.append(page.get_text())

                # Lấy ảnh rồi OCR
                for img in page.get_images(full=True):
                    try:
                        xref = img[0]
                        image_data = pdf.extract_image(xref)["image"]
                        text = ocr_preserve_layout(
                            image_data, lang="eng+vie", psm=6)
                        all_text_image.append(text)
                    except Exception as e:
                        print(
                            f"⚠️ Lỗi OCR ảnh trang {page_num} của {pdf_file.name}: {e}")
                        continue

            text_output = "\n".join(all_text)

            data.append({
                "file_name": pdf_file.stem.strip(),
                "text_image": "\n\n".join(all_text_image),
                "text": text_output
            })
        return data

    def extract_all(self):
        all_data = []

        # DOCX
        # all_data.extend(self.extract_text_from_images_in_docx())

        # PDF
        all_data.extend(self.extract_text_from_images_in_pdf())

        return all_data

    def detect_ai_text(self, text):
        """Trả về xác suất văn bản là do AI viết (0–1)."""
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True)
        outputs = self.model(**inputs)
        probs = torch.softmax(outputs.logits, dim=1)
        ai_score = probs[0][1].item()
        return ai_score

    def analyze_submissions(self, THRESHOLD_POINT_CHECK_AI=0.2):
        results = []
        for text in self.extract_all():
            text_image = self.detect_ai_text(text['text_image'])
            text_normal = self.detect_ai_text(text['text'])
            ai_score = round((text_normal + text_image) * 10, 3)
            minus = round(ai_score * THRESHOLD_POINT_CHECK_AI, 3)
            level, response = classify_level_use_ai(ai_score, minus)
            results.append({
                "file_name": text["file_name"],
                "ai_score": ai_score,
                "minus": minus,
                "level": level,
                "response": response
            })

        return results
