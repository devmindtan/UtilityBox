from pytesseract import Output
import io
from pathlib import Path
from docx import Document
from PIL import Image
import pytesseract
import os
from transformers import AutoModelForSequenceClassification, AutoTokenizer, logging
import torch

logging.set_verbosity_error()
# ========== CONFIG ==========
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
os.environ['TESSDATA_PREFIX'] = r"C:\Program Files\Tesseract-OCR\tessdata"
FOLDER_PATH = r"C:\Documents\Code\UtilityBox\AutoGrading\Tuan 6"

# ========== HÀM ==========
file_path = r"C:\Documents\Code\UtilityBox\AutoGrading\Tuan 6\2400113059_LamTaiChanh_Lab6.docx"


def ocr_preserve_layout(img_data, lang="eng+vie", psm=6):
    try:
        # Mở ảnh từ bytes
        img = Image.open(io.BytesIO(img_data)).convert("RGB")

        # Lấy dữ liệu chi tiết từng từ
        data = pytesseract.image_to_data(
            img,
            lang=lang,
            config=f"--psm {psm}",
            output_type=Output.DICT
        )

        # Gom text theo block và line
        blocks = {}
        for i, text in enumerate(data["text"]):
            if text.strip():
                block = data["block_num"][i]
                line = data["line_num"][i]
                blocks.setdefault(block, {})
                blocks[block].setdefault(line, [])
                blocks[block][line].append(text)

        # Gộp thành text, có cách dòng giữa các block
        text = "\n\n".join(
            "\n".join(" ".join(blocks[b][l]) for l in sorted(blocks[b]))
            for b in sorted(blocks)
        )

        return text.strip()

    except Exception as e:
        print(f"Lỗi OCR: {e}")
        return ""


def extract_text_from_images_in_docx():
    folder_path = Path(FOLDER_PATH)
    data = []
    for doc_file in folder_path.glob("*.docx"):
        doc = Document(doc_file)
        rels = doc.part.rels
        all_text_image = []

        all_text = [p.text.strip() for p in doc.paragraphs if p.text.strip()]
        text_output = "\n".join(all_text)

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

        data.append({
            "file_name": doc_file.stem.strip(),
            "text_image":  "\n\n".join(all_text_image),
            "text": text_output
        })

    return data


model_name = "roberta-base-openai-detector"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)


def detect_ai_text(text):
    """Trả về xác suất văn bản là do AI viết (0–1)."""
    inputs = tokenizer(text, return_tensors="pt", truncation=True)
    outputs = model(**inputs)
    probs = torch.softmax(outputs.logits, dim=1)
    ai_score = probs[0][1].item()
    return ai_score


def analyze_submissions():
    results = []
    for text in extract_text_from_images_in_docx():
        text_image = detect_ai_text(text['text_image'])
        text_normal = detect_ai_text(text['text'])
        ai_score = (text_normal + text_image) * 10
        results.append({
            "file_name": text["file_name"],
            "ai_score": round(ai_score, 3)
        })

    return results


if __name__ == "__main__":
    output = analyze_submissions()
    for r in output:
        print(f"📄 {r['file_name']}: AI score = {r['ai_score']}")
