import sys
import time
from pathlib import Path
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains import RetrievalQA
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers import EnsembleRetriever
from langchain.prompts import PromptTemplate
from langchain_core.documents import Document

# Xử lý PATH
current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.append(str(current_dir))

try:
    from config import Config
    from prompts import RouterPrompts, ExecutionPrompts
except ImportError:
    from app.service.rag.config import Config
    from app.service.rag.prompts import RouterPrompts, ExecutionPrompts

class RAGEngine:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(model_name=Config.EMBEDDING_MODEL)
        
        # Kết nối tới ChromaDB
        self.vector_db = Chroma(persist_directory=Config.VECTOR_DB_PATH, embedding_function=self.embeddings)
        
        # Cấu hình chung cho LLM, bật thêm tính năng max_retries để tự động thử lại khi nghẽn mạng
        llm_kwargs = {
            "model": Config.LLM_MODEL,
            "google_api_key": Config.GOOGLE_API_KEY,
            "max_retries": 2
        }
        
        self.llm = ChatGoogleGenerativeAI(temperature=0.2, **llm_kwargs)
        self.router_llm = ChatGoogleGenerativeAI(temperature=0.0, **llm_kwargs)
        
        # Khởi tạo sẵn Hybrid Retriever
        self.hybrid_retriever = self._setup_hybrid_retriever()

    def _setup_hybrid_retriever(self):
        """Xây dựng bộ tìm kiếm lai Hybrid (Vector + BM25)"""
        vector_retriever = self.vector_db.as_retriever(search_kwargs={"k": Config.K_VECTOR})

        print("📊 Đang xây dựng lại chỉ mục từ khóa BM25 từ Vector DB...")
        all_docs = self.vector_db.get()
        
        if not all_docs['documents']:
            print("⚠️ Cảnh báo: Vector DB hiện tại đang trống rỗng!")
            return vector_retriever
            
        documents = [
            Document(page_content=text, metadata=meta) 
            for text, meta in zip(all_docs['documents'], all_docs['metadatas'])
        ]
        bm25_retriever = BM25Retriever.from_documents(documents)
        bm25_retriever.k = Config.K_BM25

        return EnsembleRetriever(
            retrievers=[bm25_retriever, vector_retriever],
            weights=[Config.ALPHA, 1 - Config.ALPHA]
        )

    def route_intent(self, query: str) -> str:
        """Sử dụng Từ điển Phân loại (Router Prompt) để lấy Tag"""
        # Tối ưu hóa: Xử lý nhanh các câu chào hỏi phổ biến không cần gọi LLM để tiết kiệm Quota
        clean_query = query.lower().strip().replace("?", "").replace("!", "")
        if clean_query in ["chào", "hi", "hello", "chào bạn", "xin chào", "bạn khỏe không"]:
            return "CHAT"

        prompt_template = PromptTemplate.from_template(
            "{router_prompt}\n\nCÂU HỎI NGƯỜI DÙNG: {query}\n\nNHÃN CHÍNH XÁC:"
        )
        chain = prompt_template | self.router_llm
        
        try:
            response = chain.invoke({
                "router_prompt": RouterPrompts.SYSTEM_ROUTER,
                "query": query
            })
            intent = response.content.strip()
            for tag in ["FIND_BOOK", "BOOK_INFO", "POLICY", "CHAT"]:
                if tag in intent:
                    return tag
        except Exception as e:
            print(f"⚠️ Cảnh báo lỗi phân loại (Có thể do cạn quota): {e}")
            # Fallback an toàn: Nếu lỗi, đẩy thẳng vào tìm kiếm sách thay vì sập hệ thống
            return "FIND_BOOK"
            
        return "CHAT"

    def ask(self, query: str):
        """Hàm xử lý chính: Định tuyến -> Áp prompt từ điển hành vi -> Trả lời bọc lỗi"""
        import datetime # Bổ sung thư viện thời gian
        
        try:
            # Lấy ngày giờ và thứ hiện tại 
            current_time = datetime.datetime.now().strftime("Hôm nay là %A, ngày %d/%m/%Y.")

            # Bước 1: Định tuyến câu hỏi
            intent = self.route_intent(query)
            print(f"🎯 Hệ thống định tuyến nhận diện Intent: {intent}")

            # Bước 2: Xử lý luồng hội thoại tự do (CHAT)
            if intent == "CHAT":
                prompt_template = PromptTemplate.from_template(
                    "{system_prompt}\n\nNgười dùng: {query}\nTrợ lý:"
                )
                chat_chain = prompt_template | self.llm
                response = chat_chain.invoke({
                    "system_prompt": ExecutionPrompts.CHAT,
                    "query": query
                })
                return {"result": response.content, "source_documents": []}

            # Bước 3: Chuẩn bị Prompt theo từ điển tương ứng từ prompts.py
            system_prompt_text = getattr(ExecutionPrompts, intent, ExecutionPrompts.CHAT)
            
            # 🌟 ĐÃ SỬA: Chèn thêm THỜI GIAN HIỆN TẠI vào prompt để AI phân tích ngày tháng
            full_template = f"""{system_prompt_text}

THỜI GIAN HIỆN TẠI CỦA HỆ THỐNG: {current_time}

NGỮ CẢNH:
{{context}}

CÂU HỎI: {{question}}

TRẢ LỜI:"""

            prompt = PromptTemplate(template=full_template, input_variables=["context", "question"])

            # Bước 4: Tạo chuỗi QA với document_prompt tối giản (Chống triệt để lỗi KeyError: location)
            # Thay vì ép trường cứng nhắc, ta để LangChain tự truyền text thô, LLM tự bóc tách thông minh
            qa_chain = RetrievalQA.from_chain_type(
                llm=self.llm,
                chain_type="stuff",
                retriever=self.hybrid_retriever,
                return_source_documents=True,
                chain_type_kwargs={
                    "prompt": prompt,
                    "document_variable_name": "context",
                    "document_prompt": PromptTemplate(
                        template="Đoạn văn bản:\n{page_content}",
                        input_variables=["page_content"]
                    )
                }
            )

            # Bước 5: Thực thi chuỗi nhận diện
            return qa_chain.invoke({"query": query})

        except Exception as e:
            error_str = str(e)
            if "429" in error_str or "Quota exceeded" in error_str:
                return {
                    "result": "⚠️ Hệ thống hiện đang quá tải lượt yêu cầu (Cạn Quota API tạm thời). Bạn vui lòng đợi khoảng 15-30 giây rồi thực hiện gửi lại câu hỏi nhé!",
                    "source_documents": []
                }
            # Các lỗi hệ thống khác ngoại lệ
            return {"result": f"Hệ thống gặp gián đoạn: {error_str}", "source_documents": []}