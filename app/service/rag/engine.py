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
            temperature=0.1 # 0.1 để trả lời chính xác hơn, ít "sáng tạo" quá mức
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
        # 1. ĐỊNH NGHĨA KHUÔN MẪU CHO TỪNG ĐOẠN VĂN BẢN (DOCUMENT PROMPT)
        # Đây là bước quan trọng nhất để AI thấy được Metadata
        document_template = """[Sách: {title}] | [TG: {author}]
Nội dung: {page_content}"""
        
        doc_prompt = PromptTemplate(
            template=document_template,
            input_variables=["page_content", "title", "author"]
        )

        # 2. PROMPT TỔNG THỂ CHO HỆ THỐNG
        template = """Bạn là một thủ thư thông minh. Dưới đây là các đoạn trích từ thư viện.
Nhiệm vụ của bạn là liệt kê TẤT CẢ các tác phẩm của tác giả được hỏi dựa vào NGỮ CẢNH cung cấp.

QUY TẮC:
- Liệt kê đầy đủ tên sách và tác giả nếu tìm thấy trong ngữ cảnh.
- Chỉ sử dụng thông tin trong phần NGỮ CẢNH.
- Nếu không thấy thông tin liên quan đến tác giả đó, hãy trả lời "Thư viện hiện chưa có dữ liệu về tác giả này".

NGỮ CẢNH:
{context}

CÂU HỎI: {question}

TRẢ LỜI:"""

        prompt = PromptTemplate(
            template=template, 
            input_variables=["context", "question"]
        )
        
        # 3. KẾT NỐI VÀO CHAIN
        return RetrievalQA.from_chain_type(
            llm=self.llm,
            chain_type="stuff",
            retriever=self.retriever,
            return_source_documents=True,
            chain_type_kwargs={
                "prompt": prompt,
                "document_variable_name": "context",
                "document_prompt": doc_prompt, # Dùng template đã định nghĩa ở trên
            }
        )
    def ask(self, query: str):
        # Trả về kết quả từ chuỗi QA
        return self.qa_chain.invoke({"query": query})