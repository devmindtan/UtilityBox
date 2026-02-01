import os
from dotenv import load_dotenv
from src.grader import Grader
from src.ocr_processor import OCRProcessor
from src.file_reader import FileReader
from src.ai_analyzer import AIAnalyzer
from src.report_generator import ReportGenerator

load_dotenv(r"C:\Documents\Code\UtilityBox\AutoGrading\.env")

# === GLOBAL VARIABLES ===
DOC_PATH = os.getenv("DOC_PATH")
TOPIC_FILE_PATH = os.getenv("TOPIC_FILE_PATH")
API_KEY = os.getenv("API_KEY")
MODEL_NAME_GEMINI = os.getenv("MODEL_NAME_GEMINI")
MODEL_NAME_DETECTOR = os.getenv("MODEL_NAME_DETECTOR")
JSON_PATH = os.getenv("JSON_PATH")
# === DECLARE ===
file_reader = FileReader(DOC_PATH, TOPIC_FILE_PATH)
ai_analyzer = AIAnalyzer(API_KEY, MODEL_NAME_GEMINI)
orc = OCRProcessor(DOC_PATH, MODEL_NAME_DETECTOR)
report = ReportGenerator(JSON_PATH)
grader = Grader(ai_analyzer)

RUBRIC = """
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 R U B R I C   C H Ấ M   Đ I Ể M
(Tổng cộng: 10 điểm)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Nộp code — 4 điểm  
   • Nộp đầy đủ file mã nguồn, đúng cấu trúc yêu cầu.  
   • Code thể hiện sự hiểu biết về nội dung bài học.  
   • Có thể chạy được và tổ chức hợp lý.

2. Giải thích ý tưởng — 4 điểm  
   • Trình bày **ý tưởng của bản thân trước khi viết code**.  
   • Mô tả cách giải quyết vấn đề, tư duy tiếp cận.  
   • Không chỉ giải thích lại từng dòng code.  

3. Kết quả chạy được — 2 điểm  
   • Chương trình chạy đúng, xuất ra kết quả hợp lý.  
   • Đáp ứng đầy đủ yêu cầu của đề bài.

> Lưu ý:  
   • Giải thích bằng **văn phong cá nhân**, không sao chép hoặc dùng AI.  
   • Nếu phát hiện đạo văn hoặc sử dụng AI không trung thực → bị trừ điểm tương ứng.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""


if __name__ == "__main__":
    output = orc.analyze_submissions()
    all_content = file_reader.read_all_content()
    print(all_content)
    topic = file_reader.read_topic()

    content_map = {doc['file_name']: doc for doc in all_content}

    for r in output:
        file_name = r['file_name']
        doc = content_map.get(file_name)

        if not doc:
            print(f"⚠️ Không tìm thấy nội dung cho file: {file_name}")
            continue

        grading = grader.grade_one(
            JSON_PATH, doc, r['level'], r['response'], topic, RUBRIC)
    report.update_scores_after_ai(output)
    report.create_excel_report()
