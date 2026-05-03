import os
import sys
from pathlib import Path

# Thêm thư mục gốc (Library-Management_RAG) vào hệ thống path của Python
root_path = Path(__file__).resolve().parent.parent.parent.parent
sys.path.append(str(root_path))

# Bây giờ mới import các module của app
from app.service.rag.engine import RAGEngine 
from app.service.rag.config import Config

# Định nghĩa các đường dẫn cơ sở nếu cần
BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data" / "pdf"

def debug_retrieval():
    # 1. Khởi tạo Engine
    try:
        engine = RAGEngine()
        print(f"✅ Đã khởi tạo RAGEngine thành công.")
    except Exception as e:
        print(f"❌ Lỗi khởi tạo Engine: {e}")
        return

    question = "Nam Cao có những tác phẩm nào?"
    print(f"\n--- ĐANG KIỂM TRA CÂU HỎI: '{question}' ---")

    # 2. Test bước TÌM KIẾM (Retrieval)
    # Tăng k lên để quét rộng hơn trong không gian Vector
    k_test = 10
    search_results = engine.vector_db.similarity_search(question, k=k_test)
    
    print(f"\n[PHẦN 1] KẾT QUẢ TRUY XUẤT TỪ VECTOR DB (Tìm thấy {len(search_results)} đoạn):")
    
    found_lao_hac = False
    for i, res in enumerate(search_results):
        # Lấy metadata an toàn
        metadata = res.metadata
        title = metadata.get('book_title') or metadata.get('title') or 'Không rõ tên'
        author = metadata.get('author') or 'Không rõ TG'
        
        # Kiểm tra nội dung text bên trong chunk
        content_preview = res.page_content[:50].replace('\n', ' ')
        
        print(f"{i+1:2d}. [Sách: {title:15s}] | [TG: {author:10s}] | Nội dung: {content_preview}...")
        
        # Kiểm tra xem Lão Hạc có xuất hiện trong metadata hoặc nội dung không
        if "Lão Hạc" in title or "Lão Hạc" in res.page_content:
            found_lao_hac = True

    print("-" * 50)
    if found_lao_hac:
        print("✅ KẾT LUẬN 1: Dữ liệu Lão Hạc CÓ tồn tại trong DB.")
    else:
        print("❌ KẾT LUẬN 1: Lão Hạc KHÔNG có trong kết quả tìm kiếm.")
        print("   -> Gợi ý: Kiểm tra khâu 'ingest' hoặc xem file PDF có bị lỗi font không.")

    # 3. Test bước TRẢ LỜI (Generation)
    print("\n[PHẦN 2] AI ĐANG TẠO CÂU TRẢ LỜI (Dựa trên context đã tìm thấy)...")
    try:
        response = engine.ask(question)
        answer = response.get('answer', '')
        
        print(f"\nCâu trả lời của AI:\n{answer}")
        print("-" * 50)
        
        if "Lão Hạc" in answer:
            print("✅ KẾT LUẬN 2: AI đã nhận diện và liệt kê đúng Lão Hạc.")
        else:
            print("❌ KẾT LUẬN 2: AI bỏ sót Lão Hạc trong câu trả lời.")
            if found_lao_hac:
                print("   -> Lỗi: Context có nhưng AI không chọn lọc được. Hãy kiểm tra lại Prompt.")
    except Exception as e:
        print(f"❌ Lỗi khi AI tạo câu trả lời: {e}")

if __name__ == "__main__":
    debug_retrieval()