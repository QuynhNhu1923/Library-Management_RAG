import sys
import os
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import List, Dict, Any

current_dir = Path(__file__).resolve().parent 
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

try:
    from rag_engine import RAGEngine
    print("✅ Đã import RAGEngine thành công.")
except ImportError as e:
    print(f"⚠️ Lỗi Import: {e}.")
    RAGEngine = None

app = FastAPI(title="Library RAG API với Router")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

engine = None
if RAGEngine:
    try:
        print("⏳ Đang khởi tạo RAG Engine kết hợp Router phân loại...")
        engine = RAGEngine()
        print("🚀 Hệ thống Router Hybrid Search đã sẵn sàng hoạt động!")
    except Exception as e:
        print(f"❌ Lỗi khởi tạo RAGEngine: {e}")

# Định nghĩa cấu trúc JSON nhận từ Frontend
class ChatRequest(BaseModel):
    question: str
    chat_history: List[Dict[str, Any]] = []

@app.post("/ask")
async def ask_question(request: ChatRequest):
    if not engine:
        raise HTTPException(status_code=500, detail="Hệ thống RAG đang ngoại tuyến (Engine chưa khởi tạo)")
    
    try:
        # 1. Tái cấu trúc câu hỏi dựa trên trí nhớ hội thoại
        standalone_query = engine.reformulate_query(request.question, request.chat_history)
        print(f"🔄 Đã dịch câu hỏi: '{request.question}' -> '{standalone_query}'")

        # 2. Xử lý RAG
        result = engine.ask(standalone_query)
        
        detailed_sources = []
        seen_docs = set()

        for doc in result.get("source_documents", []):
            source_key = doc.metadata.get("source", doc.metadata.get("file_name", "Nguồn ẩn danh"))
            
            if source_key not in seen_docs:
                book_title = doc.metadata.get("title", Path(source_key).stem if source_key else "Văn bản nội quy")
                author = doc.metadata.get("author", "Ban quản lý thư viện")
                
                detailed_sources.append({
                    "file_name": source_key,
                    "book_title": book_title,
                    "author": author,
                    "page": doc.metadata.get("page", 0) + 1,
                    "full_info": doc.metadata.get("full_info", "")
                })
                seen_docs.add(source_key)

        return {
            "answer": result.get("result", "Không có câu trả lời từ LLM"),
            "sources": detailed_sources,
            "status": "success"
        }
    except Exception as e:
        print(f"❌ Lỗi xử lý câu hỏi tại API: {str(e)}")
        return {"answer": f"Lỗi xử lý hệ thống: {str(e)}", "status": "error"}

@app.post("/ask_stream")
async def ask_question_stream(request: ChatRequest):
    if not engine:
        raise HTTPException(status_code=500, detail="Hệ thống RAG đang ngoại tuyến")
    
    # Viết lại câu hỏi trước khi stream
    standalone_query = engine.reformulate_query(request.question, request.chat_history)
    
    return StreamingResponse(
        engine.ask_stream(standalone_query), 
        media_type="text/event-stream"
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
