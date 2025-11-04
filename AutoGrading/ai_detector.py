from pytesseract import Output
import io
from pathlib import Path
from docx import Document
from PIL import Image
import pytesseract
import os
from transformers import AutoModelForSequenceClassification, AutoTokenizer, logging
import torch
import json
from math import ceil, floor

logging.set_verbosity_error()
# ========== CONFIG ==========
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
os.environ['TESSDATA_PREFIX'] = r"C:\Program Files\Tesseract-OCR\tessdata"
FOLDER_PATH = r"C:\Documents\Code\UtilityBox\AutoGrading\Tuan 6"
THRESHOLD_POINT_CHECK_AI = 0.2
JSON_PATH = r"C:\Documents\Code\UtilityBox\AutoGrading\output.json"
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


def classify_level_use_ai(ai_score, minus):
    level = ""
    response = ""
    if ai_score >= 15:
        level = "Bài làm gần như do AI tạo ra hoàn toàn"
        response = f"Khả năng cực cao bài này được sinh ra hoàn toàn bởi AI. Hầu như không có dấu hiệu can thiệp thủ công. Bài của bạn sẽ bị trừ {minus}đ"
    elif ai_score >= 10:
        level = "Phụ thuộc nhiều vào AI"
        response = f"Phần lớn nội dung có dấu hiệu được sinh ra bởi AI. Bài làm thiếu dấu ấn cá nhân, tư duy riêng và sai khác với cách diễn đạt của sinh viên. Bài của bạn sẽ bị trừ {minus}đ"
    elif ai_score >= 5:
        level = "Khả năng cao sử dụng AI"
        response = f"Bài làm có nhiều phần trùng khớp với đặc trưng của văn bản sinh bởi AI. Nhiều câu, đoạn văn thể hiện độ mượt bất thường. Bài của bạn sẽ bị trừ {minus}đ"
    elif ai_score > 1:
        level = "Có dấu hiệu AI nhưng trong giới hạn cho phép"
        response = "Bài làm có dấu hiệu AI nhẹ, nhưng vẫn trong mức cho phép. Cách diễn đạt và cấu trúc nội dung khá trôi chảy, tự nhiên. Bạn sẽ không bị trừ điểm vì yếu tố này."
    else:
        level = "Không phát hiện dấu hiệu AI"
        response = "Bài làm thể hiện sự trung thực và nỗ lực rõ rệt của sinh viên. Cách diễn đạt tự nhiên, mạch lạc và có tư duy riêng. Rất đáng khen vì em không phụ thuộc vào AI."

    return level, response


def analyze_submissions():
    results = []
    for text in extract_text_from_images_in_docx():
        text_image = detect_ai_text(text['text_image'])
        text_normal = detect_ai_text(text['text'])
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


def update_scores_after_ai(output):
    with open(JSON_PATH, "r", encoding="UTF-8") as f:
        data_json = json.load(f)
    for r in output:
        print(
            f"📄 {r['file_name']}: AI score = {r['ai_score']} -> Sẽ bị trừ: {r['minus']}đ")
        for obj in data_json:
            name = obj.get("name", "")
            if (name == r['file_name']):
                point = float(
                    obj.get("total_point", 0)) - float(r.get("minus", 0))
                if (int(point) - point >= 0.5):
                    obj['total_point'] = ceil(point)
                elif (int(point) - point < 0.5):
                    obj['total_point'] = floor(point)
                break

    with open(JSON_PATH, "w", encoding="UTF-8") as f:
        json.dump(data_json, f, ensure_ascii=False, indent=4)
    print("✅ Đã cập nhật và lưu file JSON thành công!")


if __name__ == "__main__":
    output = analyze_submissions()
    update_scores_after_ai(output)
