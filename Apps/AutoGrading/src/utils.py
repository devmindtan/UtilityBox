import io
import json
import re
from PIL import Image
import filetype
import pytesseract
from pytesseract import Output
import os


# ========== CONFIG ==========
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
os.environ['TESSDATA_PREFIX'] = r"C:\Program Files\Tesseract-OCR\tessdata"


def detect_mine_type(image_data):
    mime_type = ""

    kind = filetype.guess(image_data)
    if kind:
        mime_type = kind.mime
    else:
        mime_type = "image/png"

    return mime_type


def safe_json_loads(text):
    # Cắt bỏ mọi thứ ngoài JSON thật
    match = re.search(r"\{.*\}", text, re.DOTALL)
    if match:
        clean = match.group(0).strip()
        return json.loads(clean)
    else:
        raise ValueError("Không tìm thấy JSON hợp lệ trong phản hồi")


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
