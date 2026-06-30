import sys
import os
import pickle
import requests
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
            "max_retries": 5
        }
        
        self.llm = ChatGoogleGenerativeAI(temperature=0.2, **llm_kwargs)
        self.router_llm = ChatGoogleGenerativeAI(temperature=0.0, **llm_kwargs)
        
        self.hybrid_retriever = self._setup_hybrid_retriever()

    def _setup_hybrid_retriever(self):
        k_vector_wide = Config.K_VECTOR 
        k_bm25_wide = Config.K_BM25
        cache_file = os.path.join(Config.VECTOR_DB_PATH, "bm25_cache.pkl")
        
        vector_retriever = self.vector_db.as_retriever(
            search_kwargs={
                "k": k_vector_wide,
                "filter": {"$or": [{"type": "child"}, {"type": "library_rules"}]}
            }
        )

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
                if meta and meta.get("type") in ["child", "library_rules"]
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

    def _expand_parents(self, docs: list) -> list:
        expanded_docs = []
        seen_parent_ids = set()
        for doc in docs:
            parent_id = doc.metadata.get("parent_id")
            if parent_id:
                if parent_id in seen_parent_ids:
                    continue
                seen_parent_ids.add(parent_id)
                try:
                    parent_res = self.vector_db.get(ids=[parent_id])
                    if parent_res and parent_res.get("documents"):
                        expanded_doc = Document(
                            page_content=parent_res["documents"][0],
                            metadata=doc.metadata.copy()
                        )
                        expanded_docs.append(expanded_doc)
                    else:
                        expanded_docs.append(doc)
                except Exception as e:
                    print(f"⚠️ Không thể khôi phục parent chunk {parent_id}: {e}")
                    expanded_docs.append(doc)
            else:
                expanded_docs.append(doc)
        return expanded_docs

    def _retrieve_context(self, query: str) -> list:
        # Kiểm tra xem có phải câu hỏi tóm tắt không
        is_summary_query = any(word in query.lower() for word in [
            "tóm tắt", "tom tat", "giới thiệu", "gioi thieu", "nội dung chính", 
            "noi dung chinh", "khái quát", "khai quat", "sơ lược", "so luoc"
        ])
        
        if is_summary_query:
            try:
                # Tìm kiếm Vector giới hạn ở type="book_summary"
                summary_results = self.vector_db.similarity_search(
                    query, 
                    k=1, 
                    filter={"type": "book_summary"}
                )
                if summary_results:
                    print(f"📚 Đã tìm thấy Summary Chunk cho: {query}")
                    return summary_results
            except Exception as e:
                print(f"⚠️ Lỗi tìm kiếm Summary Chunk: {e}")
        
        # Truy xuất chuẩn (chỉ tìm trên child/rules do bộ lọc cấu hình ở retriever) + mở rộng cha
        docs = self.hybrid_retriever.invoke(query)
        return self._expand_parents(docs)

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

            if intent == "FIND_BOOK":
                # 1. Gọi LLM trích xuất từ khóa tìm kiếm chính
                keyword_prompt = f"""Hãy trích xuất 1 từ khóa tìm kiếm chính (tên sách, tên tác giả, tên nhà xuất bản hoặc thể loại) từ câu hỏi sau. 
                Chỉ trả về duy nhất từ khóa đó, không thêm bất kỳ từ giải thích nào khác. 
                Nếu câu hỏi quá mơ hồ và không có từ khóa tìm kiếm rõ ràng, hãy trả về 'ALL'.
                
                Câu hỏi: {query}
                Từ khóa:"""
                keyword = self.llm.invoke(keyword_prompt).content.strip()
                print(f"🔍 Trích xuất từ khóa tìm kiếm: '{keyword}'")

                # 2. Gọi Rails API tìm kiếm sách
                rails_books = []
                if keyword and keyword != "ALL":
                    try:
                        url = "http://127.0.0.1:3000/api_rag/rag_data/search"
                        response = requests.get(url, params={"query": keyword}, timeout=5)
                        response.raise_for_status()
                        json_res = response.json()
                        if json_res.get("status") == "success":
                            rails_books = json_res.get("data", [])
                    except Exception as e:
                        print(f"⚠️ Lỗi truy cập Rails search API: {e}")
                
                # 3. Định dạng danh sách sách tìm thấy để chuyển cho LLM trả lời
                if rails_books:
                    books_context = "\n".join([
                        f"- Sách \"{b['title']}\" của tác giả {b['author']}, NXB {b['publisher']} ({b['publication_year']}). Thể loại: {b['categories']}. Sẵn có: {b['available_quantity']}/{b['total_quantity']} cuốn. Lượt mượn: {b['borrow_count']}. Đánh giá: {b['average_rating']}/5."
                        for b in rails_books
                    ])
                    full_prompt = f"""{ExecutionPrompts.FIND_BOOK}
                    NGỮ CẢNH TÌM THẤY TỪ HỆ THỐNG:
                    {books_context}
                    
                    CÂU HỎI NGƯỜI DÙNG: {query}
                    TRẢ LỜI:"""
                    
                    rag_chain = self.llm | StrOutputParser()
                    response_text = rag_chain.invoke(full_prompt)
                    
                    # Trả về các Document tương ứng để chatbot hiển thị nguồn
                    source_docs = [
                        Document(
                            page_content=b['full_metadata_text'],
                            metadata={"source": b['file_name'], "title": b['title'], "author": b['author']}
                        )
                        for b in rails_books
                    ]
                    return {"result": response_text, "source_documents": source_docs}
                else:
                    fallback_prompt = f"""{ExecutionPrompts.FIND_BOOK}
                    NGỮ CẢNH TÌM THẤY TỪ HỆ THỐNG:
                    Không tìm thấy sách nào khớp với từ khóa '{keyword}' trong cơ sở dữ liệu.
                    
                    CÂU HỎI NGƯỜI DÙNG: {query}
                    TRẢ LỜI:"""
                    rag_chain = self.llm | StrOutputParser()
                    response_text = rag_chain.invoke(fallback_prompt)
                    return {"result": response_text, "source_documents": []}

            # Lấy ngữ cảnh theo cơ chế Hierarchical / Summary RAG
            docs = self._retrieve_context(query)
            context_items = []
            for i, doc in enumerate(docs, 1):
                title = doc.metadata.get("title", doc.metadata.get("file_name", "Tài liệu"))
                page = doc.metadata.get("page", 0) + 1
                context_items.append(f"Đoạn văn bản {i} (Sách: {title}, Trang: {page}):\n{doc.page_content}")
            context_text = "\n\n".join(context_items)

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

            if intent == "FIND_BOOK":
                keyword_prompt = f"""Hãy trích xuất 1 từ khóa tìm kiếm chính (tên sách, tên tác giả, tên nhà xuất bản hoặc thể loại) từ câu hỏi sau. 
                Chỉ trả về duy nhất từ khóa đó, không thêm bất kỳ từ giải thích nào khác. 
                Nếu câu hỏi quá mơ hồ và không có từ khóa tìm kiếm rõ ràng, hãy trả về 'ALL'.
                
                Câu hỏi: {query}
                Từ khóa:"""
                keyword = self.llm.invoke(keyword_prompt).content.strip()
                print(f"🔍 [Stream] Trích xuất từ khóa tìm kiếm: '{keyword}'")

                rails_books = []
                if keyword and keyword != "ALL":
                    try:
                        url = "http://127.0.0.1:3000/api_rag/rag_data/search"
                        response = requests.get(url, params={"query": keyword}, timeout=5)
                        response.raise_for_status()
                        json_res = response.json()
                        if json_res.get("status") == "success":
                            rails_books = json_res.get("data", [])
                    except Exception as e:
                        print(f"⚠️ Lỗi truy cập Rails search API: {e}")

                if rails_books:
                    detailed_sources = [
                        {
                            "file_name": b['file_name'],
                            "book_title": b['title'],
                            "author": b['author'],
                            "page": 1
                        }
                        for b in rails_books
                    ]
                    yield f"data: {json.dumps({'type': 'sources', 'data': detailed_sources})}\n\n"

                    books_context = "\n".join([
                        f"- Sách \"{b['title']}\" của tác giả {b['author']}, NXB {b['publisher']} ({b['publication_year']}). Thể loại: {b['categories']}. Sẵn có: {b['available_quantity']}/{b['total_quantity']} cuốn. Lượt mượn: {b['borrow_count']}. Đánh giá: {b['average_rating']}/5."
                        for b in rails_books
                    ])
                    full_prompt = f"""{ExecutionPrompts.FIND_BOOK}
                    NGỮ CẢNH TÌM THẤY TỪ HỆ THỐNG:
                    {books_context}
                    
                    CÂU HỎI NGƯỜI DÙNG: {query}
                    TRẢ LỜI:"""
                else:
                    yield f"data: {json.dumps({'type': 'sources', 'data': []})}\n\n"
                    full_prompt = f"""{ExecutionPrompts.FIND_BOOK}
                    NGỮ CẢNH TÌM THẤY TỪ HỆ THỐNG:
                    Không tìm thấy sách nào khớp với từ khóa '{keyword}' trong cơ sở dữ liệu.
                    
                    CÂU HỎI NGƯỜI DÙNG: {query}
                    TRẢ LỜI:"""

                chat_chain = self.llm | StrOutputParser()
                for text_chunk in chat_chain.stream(full_prompt):
                    if text_chunk:
                        yield f"data: {json.dumps({'type': 'text', 'text': text_chunk})}\n\n"
                return

            # Lấy ngữ cảnh theo cơ chế Hierarchical / Summary RAG
            docs = self._retrieve_context(query)
            seen_docs = set()
            detailed_sources = []
            context_items = []
            
            for i, doc in enumerate(docs, 1):
                source_key = doc.metadata.get("source", doc.metadata.get("file_name", "Nguồn ẩn danh"))
                if source_key not in seen_docs:
                    detailed_sources.append({
                        "file_name": source_key,
                        "book_title": doc.metadata.get("title", Path(source_key).stem if source_key else "Văn bản"),
                        "author": doc.metadata.get("author", "Thư viện"),
                        "page": doc.metadata.get("page", 0) + 1
                    })
                    seen_docs.add(source_key)
                
                title = doc.metadata.get("title", Path(source_key).stem if source_key else "Tài liệu")
                page = doc.metadata.get("page", 0) + 1
                context_items.append(f"Đoạn văn bản {i} (Sách: {title}, Trang: {page}):\n{doc.page_content}")
            
            context_text = "\n\n".join(context_items)

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
