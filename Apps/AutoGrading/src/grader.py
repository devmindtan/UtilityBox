from src.prompt_builder import PromptBuilder
from src.utils import safe_json_loads
import json
import os


class Grader:
    def __init__(self, ai_analyzer):
        self.ai_analyzer = ai_analyzer

    def _grade_single_doc(self, doc, level, response, topic, RUBRIC):
        """Hàm nội bộ: chấm 1 bài, trả về dict"""
        print(f"📄 {doc['file_name']} — Đã đọc {len(doc['images'])} ảnh")

        prompt_text = PromptBuilder.create_prompt(
            doc['file_name'], doc['text'], level, response, topic, RUBRIC
        )
        res = self.ai_analyzer.genemi_call(prompt_text, doc['images'])
        return safe_json_loads(res)

    def grade_all(self, output_json, all_content, level, response, topic, RUBRIC):
        """Chấm toàn bộ bài trong all_content"""
        all_res = []

        for doc in all_content:
            try:
                result = self._grade_single_doc(
                    doc, level, response, topic, RUBRIC)
                all_res.append(result)
            except Exception as e:
                print(f"⚠️ Lỗi khi chấm {doc['file_name']}: {e}")

        # Ghi kết quả an toàn (ghi đè hoàn toàn)
        with open(output_json, "w", encoding="utf-8") as f:
            json.dump(all_res, f, ensure_ascii=False, indent=4)

        print(f"✅ Đã lưu {len(all_res)} kết quả vào {output_json}")
        return all_res

    def grade_one(self, output_json, doc, level, response, topic, RUBRIC):
        result = self._grade_single_doc(doc, level, response, topic, RUBRIC)

        # Nếu file chưa tồn tại → tạo mảng JSON mới
        if not os.path.exists(output_json):
            with open(output_json, "w", encoding="utf-8") as f:
                json.dump([result], f, ensure_ascii=False, indent=4)
        else:
            # Đọc file cũ rồi append kết quả mới
            with open(output_json, "r", encoding="utf-8") as f:
                try:
                    data = json.load(f)
                except json.JSONDecodeError:
                    data = []
            data.append(result)
            with open(output_json, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=4)

        print(f"✅ Đã chấm xong {doc['file_name']}")
        return result
