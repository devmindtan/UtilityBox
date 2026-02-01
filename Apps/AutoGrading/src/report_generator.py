import json
from pathlib import Path
import pandas as pd
from math import ceil, floor


class ReportGenerator:
    def __init__(self, JSON_PATH):
        self.json_path = Path(JSON_PATH)

    def create_excel_report(self, excel_file="output.xlsx"):
        sheet_name = "Kết quả chấm điểm"

        # Đọc JSON
        with open(self.json_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        for d in data:
            d['detail'] = "\n".join(
                [f"• {k}: {v}" for k, v in d['detail'].items()])

            d['ai_review'] = "\n".join(
                [f"• {k}: {v}" for k, v in d['ai_review'].items()])

        #  Tạo DataFrame
        # Chứa tất cả các cột: name, total_point, detail, general
        df = pd.DataFrame(data)

        # Excel writer với xlsxwriter
        writer = pd.ExcelWriter(excel_file, engine='xlsxwriter')
        df.to_excel(writer, index=False, sheet_name=sheet_name)

        workbook = writer.book
        worksheet = writer.sheets[sheet_name]

        # Format wrap text + middle align
        cell_format_1 = workbook.add_format({
            'align': 'center',
            'valign': 'vcenter',
            'text_wrap': True
        })
        cell_format_2 = workbook.add_format({
            'valign': 'vcenter',
            'text_wrap': True
        })

        # Áp dụng format + auto column width
        for i, col in enumerate(df.columns):
            max_len = max(df[col].astype(str).map(len).max(), len(col)) + 2
            max_len = min(max_len, 80)  # giới hạn max width 80

            if i < 2:  # chỉ 2 cột đầu
                worksheet.set_column(i, i, max_len, cell_format_1)
            else:  # các cột còn lại
                worksheet.set_column(i, i, max_len, cell_format_2)

        # Lưu file
        writer.close()
        print("✅ Đã tạo file output.xlsx")

    def update_scores_after_ai(self, output):
        with open(self.json_path, "r", encoding="UTF-8") as f:
            data_json = json.load(f)
        for r in output:
            print(
                f"📄 {r['file_name']}: AI score = {r['ai_score']} -> Sẽ bị trừ: {r['minus']}đ")
            for obj in data_json:
                name = obj.get("name", "")
                if (name == r['file_name']):
                    point = float(
                        obj.get("total_point", 0)) - float(r.get("minus", 0))
                    if (point - int(point) >= 0.5):
                        obj['total_point'] = ceil(point)
                    elif (point - int(point) < 0.5):
                        obj['total_point'] = floor(point)
                    break

        with open(self.json_path, "w", encoding="UTF-8") as f:
            json.dump(data_json, f, ensure_ascii=False, indent=4)
        print("✅ Đã cập nhật và lưu file JSON thành công!")
