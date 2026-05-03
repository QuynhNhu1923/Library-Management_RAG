import sys
from pathlib import Path
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains import RetrievalQA
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers import EnsembleRetriever
from langchain.prompts import PromptTemplate
from langchain_core.documents import Document

# --- PHẦN XỬ LÝ PATH GIỮ NGUYÊN ---
current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.append(str(current_dir))

try:
    from config import Config
except ImportError:
    from app.service.rag.config import Config

class RAGEngine:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(model_name=Config.EMBEDDING_MODEL)
        self.vector_db = Chroma(persist_directory=Config.VECTOR_DB_PATH, embedding_function=self.embeddings)
        self.llm = ChatGoogleGenerativeAI(
            model=Config.LLM_MODEL, 
            google_api_key=Config.GOOGLE_API_KEY, 
            temperature=0.2 # Giảm xuống 0.2 để trả lời chính xác hơn, ít "sáng tạo" quá mức
        )
        
        self.retriever = self._setup_hybrid_retriever()
        self.qa_chain = self._setup_qa_chain()

    def _setup_hybrid_retriever(self):
        vector_retriever = self.vector_db.as_retriever(search_kwargs={"k": Config.K_VECTOR})

        print("📊 Đang xây dựng chỉ mục BM25 từ Vector DB...")
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

    def _setup_qa_chain(self):
        # NÂNG CẤP PROMPT: Yêu cầu LLM đọc kỹ Metadata
        template = """Bạn là Thủ thư AI chuyên nghiệp của hệ thống quản lý thư viện.
Sử dụng NGỮ CẢNH (bao gồm nội dung sách và thông tin quản lý) dưới đây để trả lời câu hỏi.

QUY TẮC TRẢ LỜI:
1. Nếu câu hỏi về tình trạng sách (còn hay hết, mượn bao nhiêu), hãy nhìn vào phần 'Thông tin quản lý' trong ngữ cảnh.
2. Nếu câu hỏi về nội dung kiến thức, hãy tổng hợp từ 'Nội dung trích dẫn'.
3. Luôn ưu tiên sự chính xác. Nếu không có thông tin trong ngữ cảnh, hãy nói "Xin lỗi, thư viện hiện không có dữ liệu về vấn đề này".
4. Phản hồi bằng tiếng Việt, lịch sự và thân thiện.

NGỮ CẢNH TRA CỨU:
{context}

CÂU HỎI CỦA NGƯỜI DÙNG: {question}

TRẢ LỜI CHI TIẾT:"""

        prompt = PromptTemplate(
            template=template, 
            input_variables=["context", "question"]
        )
        
        # SỬA LỖI TẠI ĐÂY: Sử dụng định dạng linh hoạt hơn
        # Thay vì ép buộc full_info và rating, ta dùng page_content mặc định
        # và xử lý metadata thủ công bên trong chuỗi RetrievalQA
        return RetrievalQA.from_chain_type(
            llm=self.llm,
            chain_type="stuff",
            retriever=self.retriever,
            return_source_documents=True,
            chain_type_kwargs={
                "prompt": prompt,
                "document_variable_name": "context",
                # Chúng ta sử dụng định dạng mặc định để tránh lỗi Missing Metadata
                # LLM sẽ nhận context là danh sách các page_content (đã được ingestor gắn metadata vào text)
            }
        )

    def ask(self, query: str):
        # Trả về kết quả từ chuỗi QA
        return self.qa_chain.invoke({"query": query})