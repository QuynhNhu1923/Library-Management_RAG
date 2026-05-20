import sys
import os
from pathlib import Path
from fastapi import FastAPI, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
# 1. Xử lý đường dẫn hệ thống để đảm bảo tìm thấy các file module
current_dir = Path(__file__).resolve().parent # Thư mục chứa main.py (app/service/rag)
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

# 2. Sửa lại Import trỏ đúng sang file rag_engine.py mới nâng cấp
try:
    from rag_engine import RAGEngine
    print("✅ Đã import RAGEngine thành công.")
except ImportError as e:
    print(f"⚠️ Lỗi Import trực tiếp: {e}. Thử cấu hình fallback...")
    try:
        from app.service.rag.rag_engine import RAGEngine
    except ImportError:
        RAGEngine = None

app = FastAPI(title="Library RAG API với Router")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Trong thực tế nên đổi thành ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# 3. Khởi tạo Engine
engine = None
if RAGEngine:
    try:
        print("⏳ Đang khởi tạo RAG Engine kết hợp Router phân loại...")
        engine = RAGEngine()
        print("🚀 Hệ thống Router Hybrid Search đã sẵn sàng hoạt động!")
    except Exception as e:
        print(f"❌ Lỗi khởi tạo RAGEngine: {e}")
else:
    print("❌ Không thể khởi tạo do class RAGEngine chưa được định nghĩa đúng đường dẫn.")

@app.post("/ask")
async def ask_question(question: str = Form(...)):
    if not engine:
        raise HTTPException(status_code=500, detail="Hệ thống RAG đang ngoại tuyến (Engine chưa khởi tạo)")
    
    try:
        # Gọi sang engine.ask() - Hàm này đã tự động chạy Router bên trong
        result = engine.ask(question)
        
        # Xử lý bóc tách tài liệu nguồn chi tiết
        detailed_sources = []
        seen_docs = set()

        for doc in result.get("source_documents", []):
            # Lấy tên file hoặc nguồn văn bản
            source_key = doc.metadata.get("source", doc.metadata.get("file_name", "Nguồn ẩn danh"))
            
            if source_key not in seen_docs:
                # Tự động tối ưu hiển thị theo loại tài liệu (Sách hoặc Nội quy)
                # Nếu không có title/author (như file nội quy) thì lấy tên file làm tiêu đề hiển thị luôn
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

if __name__ == "__main__":
    import uvicorn
    # Khởi chạy server FastAPI tại port 8000
    uvicorn.run(app, host="127.0.0.1", port=8000)