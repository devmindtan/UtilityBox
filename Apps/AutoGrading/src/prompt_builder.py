class PromptBuilder:
    @staticmethod
    def create_prompt(file_name, content, level, response, topic_content, RUBRIC):
        """
        Sinh prompt yêu cầu mô hình AI chấm điểm và nhận xét bài sinh viên.
        (Không can thiệp vào điểm dựa theo mức độ AI — phần đó xử lý sau.)

        Parameters:
            file_name (str): Tên file bài nộp.
            content (str): Nội dung bài làm (text).
            level (str): Mức độ sử dụng AI (từ classify_level_use_ai).
            response (str): Phản hồi mô tả mức độ AI (ảnh hưởng đến giọng nhận xét).
            topic_content (callable hoặc str): Nội dung đề bài.
            RUBRIC (str): Chuỗi rubric đánh giá.

        Returns:
            str: Chuỗi prompt hoàn chỉnh.
        """
        return f"""
        Bạn là giảng viên đại học đang chấm bài sinh viên. Hãy đọc kỹ **đề bài**, **rubric**, và **nội dung bài làm** (bao gồm cả text và hình ảnh nếu có).

        ## 🎯 Nhiệm vụ:
        1. Đánh giá chi tiết từng tiêu chí trong rubric.
        2. Ghi rõ điểm cho từng tiêu chí (thang 10, không làm tròn).
        3. Tính **tổng điểm (thang 10)** — làm tròn .5 trở lên là lên, dưới .5 là xuống.
        4. Viết nhận xét ngắn gọn (dưới 30 chữ mỗi tiêu chí), chuyên nghiệp, xưng "em".
        5. **Điểm số không bị ảnh hưởng bởi việc sử dụng AI** — chỉ đánh giá chất lượng bài làm.
        6. Khi viết nhận xét, có thể **điều chỉnh ngữ điệu** dựa theo phản hồi sau:
        🧩 *"{response}"*

        → Nếu phản hồi mang tính **khích lệ**: dùng giọng **tích cực, động viên, đánh giá cao nỗ lực cá nhân**.  
        → Nếu phản hồi mang tính **cảnh báo hoặc nghi ngờ AI**: dùng giọng **khách quan, chuyên nghiệp, nhẹ nhàng nhưng rõ ràng**.

        7. Trả về **duy nhất một JSON hợp lệ** theo mẫu sau:

        ---
        {{
        "name": "{file_name}",
        "total_point": <số điểm trên 10>,
        "detail": {{
            "Tên tiêu chí 1": "<Điểm> điểm — [Nhận xét ngắn]",
            "Tên tiêu chí 2": "<Điểm> điểm — [Nhận xét ngắn]",
            ...
        }},
        "general": "<nhận xét tổng quát 1–2 câu>",
        "ai_review": {{
            "Mức độ": "{level}",
            "Phản hồi": "{response}"
        }}
        }}
        ---

        ## 📘 Thông tin chấm:
        **Đề bài:**
        {topic_content}

        **Rubric:**
        {RUBRIC}

        **Nội dung bài làm (text):**
        {content}

        Nếu có hình ảnh, hãy xét nội dung trong ảnh nữa.
        """
