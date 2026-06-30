import os
from pathlib import Path
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from config import Config

# --- CẤU HÌNH ĐƯỜNG DẪN ---
# lưu ý đường dẫn này phải khớp hoàn toàn với ingestor.py
VECTOR_DB_DIR = Config.VECTOR_DB_PATH

def check_database():
    print("\n--- 🔍 ĐANG KIỂM TRA DỮ LIỆU TRONG VECTOR DATABASE ---")

    # 1. Kiểm tra xem thư mục có tồn tại không
    if not os.path.exists(VECTOR_DB_DIR):
        print(f"❌ Lỗi: Thư mục {VECTOR_DB_DIR} không tồn tại!")
        return

    try:
        # 2. Khởi tạo Local Embedding Model (phải giống hệt lúc nạp)
        print("⏳ Đang khởi tạo Embedding Model để đọc dữ liệu...")
        embeddings = HuggingFaceEmbeddings(
            model_name=Config.EMBEDDING_MODEL
        )
        
        # 3. Kết nối tới ChromaDB
        vector_db = Chroma(persist_directory=VECTOR_DB_DIR, embedding_function=embeddings)
        
        # 4. Lấy toàn bộ dữ liệu metadata
        results = vector_db.get()
        all_metadatas = results.get('metadatas', [])

        if not all_metadatas:
            print("💀 Database hiện tại đang TRỐNG RỖNG (0 chunks).")
            return

        # 5. Đếm số lượng chunks (đoạn văn bản nhỏ)
        print(f"📊 Tổng số đoạn văn bản (chunks) đã lưu: {len(all_metadatas)}")

        # 6. Trích xuất danh sách các file PDF duy nhất
        # Lưu ý: 'source' là key mà ingestordùng để lưu tên file
        sources = set()
        for meta in all_metadatas:
            if 'source' in meta:
                sources.add(meta['source'])
            elif 'source_title' in meta:
                sources.add(meta['source_title'])

        # 7. Hiển thị kết quả
        print(f"📚 Tìm thấy {len(sources)} file sách đã được nạp thành công:")
        for i, source in enumerate(sorted(sources), 1):
            # Đếm xem mỗi file có bao nhiêu chunks
            file_chunks = sum(1 for m in all_metadatas if m.get('source') == source or m.get('source_title') == source)
            print(f"   {i}. {source} ({file_chunks} chunks)")

    except Exception as e:
        print(f"❌ Có lỗi xảy ra khi kiểm tra: {str(e)}")

if __name__ == "__main__":
    check_database()
    print("\n--- ✅ HOÀN TẤT KIỂM TRA ---")