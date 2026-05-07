import sys
from pathlib import Path
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers import EnsembleRetriever
from langchain_core.documents import Document

# --- PHẦN XỬ LÝ PATH ---
current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.append(str(current_dir))

try:
    from config import Config
    # Import tất cả từ prompts.py
    from prompts import ROUTER_TEMPLATE, PROMPT_LIBRARY, DOC_PROMPT
except ImportError:
    from app.service.rag.config import Config
    from app.service.rag.prompts import ROUTER_TEMPLATE, PROMPT_LIBRARY, DOC_PROMPT

class RAGEngine:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(model_name=Config.EMBEDDING_MODEL)
        self.vector_db = Chroma(persist_directory=Config.VECTOR_DB_PATH, embedding_function=self.embeddings)
        self.llm = ChatGoogleGenerativeAI(
            model=Config.LLM_MODEL, 
            google_api_key=Config.GOOGLE_API_KEY, 
            temperature=0.1
        )
        
        self.retriever = self._setup_hybrid_retriever()

    def _setup_hybrid_retriever(self):
        """Khởi tạo Hybrid Retriever (Vector + BM25)"""
        vector_retriever = self.vector_db.as_retriever(search_kwargs={"k": Config.K_VECTOR})
        
        # Xây dựng BM25 từ toàn bộ tài liệu trong Vector DB
        all_docs = self.vector_db.get()
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

    def _get_intent(self, query):
        """Router: Phân loại ý định sử dụng template từ prompts.py"""
        formatted_router = ROUTER_TEMPLATE.format(query=query)
        response = self.llm.invoke(formatted_router)
        intent = response.content.strip().upper()
        
        # Nếu LLM trả ra nhãn lạ, mặc định về CHAT
        return intent if intent in PROMPT_LIBRARY else "CHAT"

    def ask(self, query: str):
        # 1. Nhận diện mục đích (Routing)
        intent = self._get_intent(query)
        print(f"🔍 [Router] Phát hiện Intent: {intent}")

        # 2. Xử lý nhóm CHAT (Không cần Retrieval để tiết kiệm tài nguyên)
        if intent == "CHAT":
            prompt_template = PROMPT_LIBRARY["CHAT"]
            final_prompt = prompt_template.format(question=query)
            ans = self.llm.invoke(final_prompt)
            return {"result": ans.content, "source_documents": [], "intent": intent}

        # 3. Truy xuất dữ liệu từ Vector DB
        # Nếu tìm sách, có thể ưu tiên tăng k (số lượng kết quả)
        if intent == "FIND_BOOK":
            self.retriever.retrievers[0].k = 10 # Tăng độ phủ cho BM25
        
        docs = self.retriever.invoke(query)

        # 4. Format context sử dụng DOC_PROMPT từ prompts.py
        context_parts = []
        for doc in docs:
            # metadata.get đảm bảo không lỗi nếu thiếu trường thông tin
            formatted_doc = DOC_PROMPT.format(
                page_content=doc.page_content,
                title=doc.metadata.get("title", "Không rõ"),
                author=doc.metadata.get("author", "Không rõ"),
                location=doc.metadata.get("location", "Liên hệ thủ thư")
            )
            context_parts.append(formatted_doc)
        
        context_text = "\n\n---\n\n".join(context_parts)

        # 5. Lấy Prompt Template tương ứng từ Library
        selected_prompt_template = PROMPT_LIBRARY[intent]
        
        # Kết hợp thành Prompt cuối cùng
        final_prompt = selected_prompt_template.format(
            context=context_text, 
            question=query
        )
        
        # 6. Gọi LLM tạo câu trả lời
        response = self.llm.invoke(final_prompt)

        return {
            "result": response.content,
            "source_documents": docs,
            "intent": intent
        }