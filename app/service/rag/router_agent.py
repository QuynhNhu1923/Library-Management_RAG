# Import từ điển prompt vừa tạo ở trên
from prompts import RouterPrompts, ExecutionPrompts
from google import genai
from google.genai import types
from config import Config

class LibraryRouterRAG:
    def __init__(self):
        self.client = genai.Client(api_key=Config.GOOGLE_API_KEY)
        self.model_name = Config.LLM_MODEL

    def route_intent(self, user_query: str) -> str:
        """Sử dụng Từ điển Phân loại (Router Prompt)"""
        response = self.client.models.generate_content(
            model=self.model_name,
            contents=user_query,
            config=types.GenerateContentConfig(
                system_instruction=RouterPrompts.SYSTEM_ROUTER, # Gọi từ file prompts.py
                temperature=0.0
            )
        )
        intent = response.text.strip()
        # Đảm bảo fallback an toàn
        return intent if intent in ["FIND_BOOK", "BOOK_INFO", "POLICY", "CHAT"] else "CHAT"

    def execute_rag(self, user_query: str):
        intent = self.route_intent(user_query)
        print(f"🎯 Khớp nhãn hệ thống: {intent}")

        # Lấy nhanh prompt thực thi tương ứng từ dictionary / class thuộc tính
        # Bằng cách sử dụng hàm getattr(), ta tự động ánh xạ nhãn intent với biến prompt tương ứng
        system_prompt = getattr(ExecutionPrompts, intent, ExecutionPrompts.CHAT)

        if intent == "CHAT":
            # Luồng chat thông thường không cần bốc dữ liệu từ ChromaDB
            full_content = user_query
        else:
            # Luồng RAG: Giả định bạn đã viết hàm lấy context thành công từ ChromaDB
            context = "Dữ liệu thực tế từ ChromaDB..." 
            full_content = f"NGỮ CẢNH:\n{context}\n\nCÂU HỎI: {user_query}"

        # Đẩy qua Gemini xử lý cuối cùng
        response = self.client.models.generate_content(
            model=self.model_name,
            contents=full_content,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt, # Prompt tự động đổi theo Intent của bạn
                temperature=0.2
            )
        )
        return response.text