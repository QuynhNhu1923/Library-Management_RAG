import sys
import os
from pathlib import Path
from fastapi import FastAPI, Form, HTTPException

# 1. Xử lý đường dẫn hệ thống để đảm bảo tìm thấy engine.py và config.py
current_dir = Path(__file__).resolve().parent # Thư mục chứa main.py (app/service/rag)
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

# 2. Import RAGEngine sau khi đã xử lý sys.path
try:
    from engine import RAGEngine
    print("✅ Đã import RAGEngine thành công.")
except ImportError as e:
    print(f"❌ Lỗi Import: Không tìm thấy file engine.py. Chi tiết: {e}")
    # Nếu chạy từ gốc dự án, thử fallback import
    try:
        from app.service.rag.engine import RAGEngine
    except ImportError:
        RAGEngine = None

app = FastAPI(title="Library RAG API")

# 3. Khởi tạo Engine
engine = None
if RAGEngine:
    try:
        print("⏳ Đang khởi tạo RAG Engine (Hybrid Search)...")
        engine = RAGEngine()
        print("🚀 Hệ thống Hybrid Search đã sẵn sàng!")
    except Exception as e:
        print(f"❌ Lỗi khởi tạo RAGEngine: {e}")
else:
    print("❌ Không thể khởi tạo do class RAGEngine chưa được định nghĩa.")

@app.post("/ask")
async def ask_question(question: str = Form(...)):
    if not engine:
        raise HTTPException(status_code=500, detail="Hệ thống RAG đang ngoại tuyến (Engine chưa khởi tạo)")
    
    try:
        result = engine.ask(question)
        
        # Xử lý lấy nguồn chi tiết
        detailed_sources = []
        seen_docs = set()

        for doc in result.get("source_documents", []):
            source_key = doc.metadata.get("source", "Nguồn ẩn danh")
            if source_key not in seen_docs:
                detailed_sources.append({
                    "file_name": source_key,
                    "book_title": doc.metadata.get("title", "Không rõ tiêu đề"),
                    "author": doc.metadata.get("author", "Không rõ tác giả"),
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
        print(f"❌ Lỗi xử lý câu hỏi: {str(e)}")
        return {"answer": f"Lỗi xử lý: {str(e)}", "status": "error"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)