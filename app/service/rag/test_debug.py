import os
import sys
from pathlib import Path

# --- PHẦN XỬ LÝ PATH ---
# Thêm thư mục gốc vào hệ thống path của Python
root_path = Path(__file__).resolve().parent.parent.parent.parent
if str(root_path) not in sys.path:
    sys.path.append(str(root_path))

try:
    from app.service.rag.engine import RAGEngine 
    from app.service.rag.config import Config
except ImportError as e:
    print(f"❌ Lỗi Import: {e}")
    print("Hãy đảm bảo bạn đang chạy file test từ đúng thư mục hoặc cấu trúc path chính xác.")
    sys.exit(1)

def debug_retrieval():
    # 1. Khởi tạo Engine
    try:
        engine = RAGEngine()
        print(f"✅ Đã khởi tạo RAGEngine thành công.")
    except Exception as e:
        print(f"❌ Lỗi khởi tạo Engine: {e}")
        return

    # Kịch bản test: Kiểm tra tra cứu tác giả (Nhóm FIND_BOOK)
    question = "Nam Cao có những tác phẩm nào?"
    print(f"\n{'='*60}")
    print(f"🚀 ĐANG KIỂM TRA CÂU HỎI: '{question}'")
    print(f"{'='*60}")

    # 2. Chạy hàm ask (Bao gồm cả Router + Retrieval + Generation)
    try:
        response = engine.ask(question)
        
        # Lấy dữ liệu từ dictionary trả về
        intent = response.get('intent', 'N/A')
        answer = response.get('result', '') # Lưu ý: Engine mới dùng key 'result'
        source_docs = response.get('source_documents', [])

        print(f"\n[PHẦN 1] KIỂM TRA ROUTER:")
        print(f"📍 Intent nhận diện: {intent}")
        if intent == "FIND_BOOK":
            print("✅ Router hoạt động đúng.")
        else:
            print(f"⚠️ Router nhận diện chưa chuẩn (Kỳ vọng: FIND_BOOK, Thực tế: {intent})")

        print(f"\n[PHẦN 2] KẾT QUẢ TRUY XUẤT (Tìm thấy {len(source_docs)} đoạn):")
        
        found_target = False
        target_book = "Lão Hạc" # Sách mục tiêu để kiểm chứng

        for i, doc in enumerate(source_docs):
            meta = doc.metadata
            # Lấy metadata theo cấu trúc trong prompts.py
            title = meta.get('title') or meta.get('book_title') or 'Không rõ tên'
            author = meta.get('author') or 'Không rõ TG'
            location = meta.get('location') or 'Không rõ vị trí'
            
            content_preview = doc.page_content[:60].replace('\n', ' ')
            
            print(f"{i+1:2d}. [Sách: {title[:20]:20s}] | [TG: {author:12s}] | [Vị trí: {location:10s}]")
            print(f"    📄 Nội dung: {content_preview}...")
            
            if target_book.lower() in title.lower() or target_book.lower() in doc.page_content.lower():
                found_target = True

        print("-" * 50)
        if found_target:
            print(f"✅ KẾT LUẬN TRUY XUẤT: Dữ liệu '{target_book}' CÓ xuất hiện trong Context.")
        else:
            print(f"❌ KẾT LUẬN TRUY XUẤT: Không tìm thấy '{target_book}' trong các đoạn trích.")

        print(f"\n[PHẦN 3] CÂU TRẢ LỜI CỦA AI:")
        print(f"-----------------------------------------------------------")
        print(answer)
        print(f"-----------------------------------------------------------")
        
        if target_book.lower() in answer.lower():
            print(f"✅ KẾT LUẬN CUỐI: AI đã liệt kê đúng '{target_book}'.")
        else:
            print(f"❌ KẾT LUẬN CUỐI: AI bỏ sót thông tin quan trọng.")

    except Exception as e:
        print(f"❌ Lỗi trong quá trình xử lý: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    debug_retrieval()