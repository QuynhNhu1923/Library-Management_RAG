import sys
from pathlib import Path
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.retrievers import BM25Retriever
from langchain_classic.retrievers import EnsembleRetriever, ContextualCompressionRetriever
from langchain_core.prompts import PromptTemplate
from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser 
from langchain_cohere import CohereRerank

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
        
        llm_kwargs = {
            "model": Config.LLM_MODEL,
            "google_api_key": Config.GOOGLE_API_KEY,
            "max_retries": 2
        }
        
        self.llm = ChatGoogleGenerativeAI(temperature=0.2, **llm_kwargs)
        self.router_llm = ChatGoogleGenerativeAI(
            temperature=0.0, 
            model=Config.LLM_MODEL, 
            google_api_key=Config.GOOGLE_API_KEY,
            max_retries=2
        )
        
        self.hybrid_retriever = self._setup_hybrid_retriever()

    def _setup_hybrid_retriever(self):
        k_vector_wide = 10 
        k_bm25_wide = 10
        
        vector_retriever = self.vector_db.as_retriever(search_kwargs={"k": k_vector_wide})

        print("📊 Đang xây dựng chỉ mục từ khóa BM25...")
        all_docs = self.vector_db.get()
        
        if not all_docs['documents']:
            print("⚠️ Cảnh báo: Vector DB hiện tại đang trống rỗng!")
            return vector_retriever
            
        documents = [
            Document(page_content=text, metadata=meta) 
            for text, meta in zip(all_docs['documents'], all_docs['metadatas'])
        ]
        bm25_retriever = BM25Retriever.from_documents(documents)
        bm25_retriever.k = k_bm25_wide

        base_ensemble_retriever = EnsembleRetriever(
            retrievers=[bm25_retriever, vector_retriever],
            weights=[Config.ALPHA, 1 - Config.ALPHA]
        )

        print("⚡ Đang kết nối màng lọc Cohere Reranker đa ngữ...")
        compressor = CohereRerank(
            cohere_api_key=Config.COHERE_API_KEY,
            model="rerank-multilingual-v3.0",
            top_n=3 
        )

        rerank_retriever = ContextualCompressionRetriever(
            base_compressor=compressor,
            base_retriever=base_ensemble_retriever
        )
        return rerank_retriever

    def route_intent(self, query: str) -> str:
        clean_query = query.lower().strip().replace("?", "").replace("!", "")
        if clean_query in ["chào", "hi", "hello", "chào bạn", "xin chào", "bạn khỏe không"]:
            return "CHAT"

        prompt_template = PromptTemplate.from_template(
            "{router_prompt}\n\nCÂU HỎI NGƯỜI DÙNG: {query}\n\nNHÃN CHÍNH XÁC:"
        )
        
        # 🌟 Sử dụng StrOutputParser() ép kết quả luôn luôn là String
        chain = prompt_template | self.router_llm | StrOutputParser()
        
        try:
            intent = chain.invoke({
                "router_prompt": RouterPrompts.SYSTEM_ROUTER,
                "query": query
            }).strip()
            
            for tag in ["FIND_BOOK", "BOOK_INFO", "POLICY", "CHAT"]:
                if tag in intent:
                    return tag
        except Exception as e:
            print(f"⚠️ Cảnh báo lỗi phân loại: {e}")
            return "FIND_BOOK"
            
        return "CHAT"

    def ask(self, query: str):
        import datetime 
        try:
            current_time = datetime.datetime.now().strftime("Hôm nay là %A, ngày %d/%m/%Y.")
            intent = self.route_intent(query)
            print(f"🎯 Hệ thống định tuyến nhận diện Intent: {intent}")

            if intent == "CHAT":
                prompt_template = PromptTemplate.from_template("{system_prompt}\n\nNgười dùng: {query}\nTrợ lý:")
                # 🌟 Ép kiểu tự động bằng Parser
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

            # 🌟 Ép kiểu cho luồng RAG
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

            # 🌟 Streaming nhả từng chữ giờ đây an toàn tuyệt đối nhờ Parser
            rag_chain = self.llm | StrOutputParser()
            for text_chunk in rag_chain.stream(full_prompt):
                if text_chunk:
                    yield f"data: {json.dumps({'type': 'text', 'text': text_chunk})}\n\n"

        except Exception as e:
            error_msg = "⚠️ Quá tải API." if "429" in str(e) else f"Lỗi: {str(e)}"
            yield f"data: {json.dumps({'type': 'text', 'text': error_msg})}\n\n"