import sys
import os
import pickle
from pathlib import Path
from pydantic import BaseModel, Field

from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.retrievers import BM25Retriever
from langchain_classic.retrievers import EnsembleRetriever, ContextualCompressionRetriever
from langchain_core.prompts import PromptTemplate
from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser 
from langchain_cohere import CohereRerank

current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.append(str(current_dir))

try:
    from config import Config
    from prompts import RouterPrompts, ExecutionPrompts
except ImportError:
    from app.service.rag.config import Config
    from app.service.rag.prompts import RouterPrompts, ExecutionPrompts

# --- ĐỊNH NGHĨA SCHEMA CHO ROUTER ---
class IntentSchema(BaseModel):
    intent: str = Field(
        description="Nhãn phân loại câu hỏi",
        enum=["FIND_BOOK", "BOOK_INFO", "POLICY", "CHAT"]
    )

class RAGEngine:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(model_name=Config.EMBEDDING_MODEL)
        self.vector_db = Chroma(persist_directory=Config.VECTOR_DB_PATH, embedding_function=self.embeddings)
        
        llm_kwargs = {
            "model": Config.LLM_MODEL,
            "google_api_key": Config.GOOGLE_API_KEY,
            "max_retries": 2
        }
        
        self.llm = ChatGoogleGenerativeAI(temperature=0.2, **llm_kwargs)
        self.router_llm = ChatGoogleGenerativeAI(temperature=0.0, **llm_kwargs)
        
        self.hybrid_retriever = self._setup_hybrid_retriever()
    
    def _setup_hybrid_retriever(self):
        k_vector_wide = Config.K_VECTOR 
        k_bm25_wide = Config.K_BM25
        cache_file = os.path.join(Config.VECTOR_DB_PATH, "bm25_cache.pkl")
        
        vector_retriever = self.vector_db.as_retriever(search_kwargs={"k": k_vector_wide})

        print("📊 Đang khởi tạo bộ lọc BM25...")
        documents = []

        # Cơ chế Caching khắc phục "bom nổ chậm" RAM
        if os.path.exists(cache_file):
            with open(cache_file, "rb") as f:
                documents = pickle.load(f)
            print("✅ Đã load BM25 từ Cache cục bộ siêu tốc!")
        else:
            print("⏳ Không tìm thấy Cache, đang quét ChromaDB (Chỉ chạy 1 lần sau khi Ingest)...")
            all_docs = self.vector_db.get()
            if not all_docs['documents']:
                print("⚠️ Cảnh báo: Vector DB hiện tại đang trống rỗng!")
                return vector_retriever
                
            documents = [
                Document(page_content=text, metadata=meta) 
                for text, meta in zip(all_docs['documents'], all_docs['metadatas'])
            ]
            with open(cache_file, "wb") as f:
                pickle.dump(documents, f)

        bm25_retriever = BM25Retriever.from_documents(documents)
        bm25_retriever.k = k_bm25_wide

        base_ensemble_retriever = EnsembleRetriever(
            retrievers=[bm25_retriever, vector_retriever],
            weights=[Config.ALPHA, 1 - Config.ALPHA]
        )

        compressor = CohereRerank(
            cohere_api_key=Config.COHERE_API_KEY,
            model="rerank-multilingual-v3.0",
            top_n=3 
        )

        return ContextualCompressionRetriever(
            base_compressor=compressor,
            base_retriever=base_ensemble_retriever
        )

    def route_intent(self, query: str) -> str:
        clean_query = query.lower().strip()
        if clean_query in ["chào", "hi", "hello", "chào bạn", "xin chào"]:
            return "CHAT"

        # Ép kiểu Structured Outputs an toàn tuyệt đối
        structured_router = self.router_llm.with_structured_output(IntentSchema)
        prompt = f"{RouterPrompts.SYSTEM_ROUTER}\n\nCÂU HỎI NGƯỜI DÙNG: {query}"
        
        try:
            result = structured_router.invoke(prompt)
            return result.intent
        except Exception as e:
            print(f"⚠️ Lỗi phân loại, tự động dùng fallback: {e}")
            return "FIND_BOOK"

    def reformulate_query(self, query: str, chat_history: list) -> str:
        """Viết lại câu hỏi dựa trên lịch sử hội thoại"""
        if not chat_history:
            return query
            
        history_text = "\n".join([f"{msg['role']}: {msg['content']}" for msg in chat_history[-3:]])
        prompt = f"""Dựa vào Lịch sử trò chuyện và Câu hỏi mới. Hãy viết lại Câu hỏi mới thành một câu hoàn chỉnh, rõ ràng, không dùng đại từ nhân xưng mập mờ (như "nó", "cuốn đó"). Nếu câu hỏi mới không liên quan lịch sử, giữ nguyên câu hỏi mới.
        
        Lịch sử:
        {history_text}
        
        Câu hỏi mới: {query}
        Câu hỏi được viết lại (Chỉ trả về câu hỏi, không giải thích):"""
        
        try:
            return self.llm.invoke(prompt).content.strip()
        except Exception:
            return query

    def ask(self, query: str):
        import datetime 
        try:
            current_time = datetime.datetime.now().strftime("Hôm nay là %A, ngày %d/%m/%Y.")
            intent = self.route_intent(query)
            print(f"🎯 Hệ thống định tuyến nhận diện Intent: {intent}")

            if intent == "CHAT":
                prompt_template = PromptTemplate.from_template("{system_prompt}\n\nNgười dùng: {query}\nTrợ lý:")
                chat_chain = prompt_template | self.llm | StrOutputParser()
                response_text = chat_chain.invoke({"system_prompt": ExecutionPrompts.CHAT, "query": query})
                return {"result": response_text, "source_documents": []}

            docs = self.hybrid_retriever.invoke(query)
            context_text = "\n\n".join([f"Đoạn văn bản:\n{doc.page_content}" for doc in docs])

            system_prompt_text = getattr(ExecutionPrompts, intent, ExecutionPrompts.CHAT)
            full_prompt = f"""{system_prompt_text}
THỜI GIAN HIỆN TẠI CỦA HỆ THỐNG: {current_time}
NGỮ CẢNH:
{context_text}
CÂU HỎI: {query}
TRẢ LỜI:"""

            rag_chain = self.llm | StrOutputParser()
            response_text = rag_chain.invoke(full_prompt)

            return {"result": response_text, "source_documents": docs}

        except Exception as e:
            if "429" in str(e) or "Quota" in str(e):
                return {"result": "⚠️ Cạn Quota API tạm thời. Vui lòng đợi lát nữa thử lại nhé!", "source_documents": []}
            return {"result": f"Hệ thống gặp gián đoạn: {str(e)}", "source_documents": []}

    def ask_stream(self, query: str):
        import datetime
        import json
        
        try:
            current_time = datetime.datetime.now().strftime("Hôm nay là %A, ngày %d/%m/%Y.")
            intent = self.route_intent(query)

            if intent == "CHAT":
                yield f"data: {json.dumps({'type': 'sources', 'data': []})}\n\n"
                full_prompt = f"{ExecutionPrompts.CHAT}\n\nNgười dùng: {query}\nTrợ lý:"
                chat_chain = self.llm | StrOutputParser()
                for text_chunk in chat_chain.stream(full_prompt):
                    if text_chunk:
                        yield f"data: {json.dumps({'type': 'text', 'text': text_chunk})}\n\n"
                return

            docs = self.hybrid_retriever.invoke(query)
            seen_docs = set()
            detailed_sources = []
            context_text = ""
            
            for doc in docs:
                source_key = doc.metadata.get("source", doc.metadata.get("file_name", "Nguồn ẩn danh"))
                if source_key not in seen_docs:
                    detailed_sources.append({
                        "file_name": source_key,
                        "book_title": doc.metadata.get("title", Path(source_key).stem if source_key else "Văn bản"),
                        "author": doc.metadata.get("author", "Thư viện"),
                        "page": doc.metadata.get("page", 0) + 1
                    })
                    seen_docs.add(source_key)
                context_text += f"Đoạn văn bản:\n{doc.page_content}\n\n"

            yield f"data: {json.dumps({'type': 'sources', 'data': detailed_sources})}\n\n"

            system_prompt_text = getattr(ExecutionPrompts, intent, ExecutionPrompts.CHAT)
            full_prompt = f"""{system_prompt_text}
THỜI GIAN HIỆN TẠI: {current_time}
NGỮ CẢNH:
{context_text}
CÂU HỎI: {query}
TRẢ LỜI:"""

            rag_chain = self.llm | StrOutputParser()
            for text_chunk in rag_chain.stream(full_prompt):
                if text_chunk:
                    yield f"data: {json.dumps({'type': 'text', 'text': text_chunk})}\n\n"

        except Exception as e:
            error_msg = "⚠️ Quá tải API." if "429" in str(e) else f"Lỗi: {str(e)}"
            yield f"data: {json.dumps({'type': 'text', 'text': error_msg})}\n\n"
