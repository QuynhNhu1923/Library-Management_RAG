import os
import requests
import hashlib
from pathlib import Path
from langchain_community.document_loaders import PyMuPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma

# Bỏ cấu hình CHECKLIST_FILE
PDF_FOLDER = "/home/quynhnhu/Projects/Library-Management_RAG/lib/assets/import_pdfs_cut"
VECTOR_DB_DIR = "/mnt/d/LibraryStorage/VectorData"
RAILS_API_URL = "http://127.0.0.1:3000/api_rag/rag_data/metadata"

def load_books_metadata_from_rails():
    print(f"📡 Đang kết nối với Rails API: {RAILS_API_URL}")
    try:
        response = requests.get(RAILS_API_URL, timeout=10)
        response.raise_for_status()
        json_data = response.json()
        
        if json_data.get("status") == "success":
            return {item['file_name']: item for item in json_data['data']}
        return {}
    except Exception as e:
        print(f"⚠️ Không thể lấy metadata từ Rails: {e}")
        return {}

def main():
    print("\n--- 🔍 BẮT ĐẦU QUY TRÌNH NẠP DỮ LIỆU THÔNG MINH ---")
    
    books_metadata = load_books_metadata_from_rails()
    
    print("⏳ Đang tải Local Embedding Model...")
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
    )
    vector_db = Chroma(persist_directory=VECTOR_DB_DIR, embedding_function=embeddings)
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)

    files = [f for f in os.listdir(PDF_FOLDER) if f.endswith(".pdf")]
    
    if not files:
        print("☕ Không tìm thấy file PDF nào trong thư mục!")
        return

    print(f"🚀 Xử lý nạp / cập nhật (Upsert) {len(files)} file PDF.")

    for filename in sorted(files):
        file_path = os.path.join(PDF_FOLDER, filename)
        print(f"\n📖 Đang xử lý: {filename}")
        
        meta_info = books_metadata.get(filename, {})
        
        try:
            loader = PyMuPDFLoader(file_path)
            pages = loader.load()
            
            if not pages:
                continue

            for page in pages:
                page.metadata["source"] = filename
                if meta_info:
                    page.metadata.update({
                        "book_id": meta_info.get("id"),
                        "title": meta_info.get("title"),
                        "author": meta_info.get("author"),
                        "publisher": meta_info.get("publisher")
                    })
            
            chunks = text_splitter.split_documents(pages)
            chunk_ids = []
            
            # Tạo ID duy nhất cho từng chunk để hỗ trợ Upsert
            for i, chunk in enumerate(chunks):
                chunk_hash = hashlib.md5(f"{filename}_chunk_{i}".encode("utf-8")).hexdigest()
                chunk_ids.append(chunk_hash)
            
            print(f"  -> Đang đẩy {len(chunks)} chunks vào ChromaDB (Ghi đè nếu đã tồn tại).")
            # Ghi đè tự động theo ids
            vector_db.add_documents(documents=chunks, ids=chunk_ids)
            
            print(f"✅ HOÀN THÀNH: {filename}")

        except Exception as e:
            print(f"❌ LỖI tại file {filename}: {str(e)}")

    # Xóa bộ đệm BM25 cũ để RAGEngine tạo lại bản mới vào lần chạy tiếp theo
    bm25_cache_path = os.path.join(VECTOR_DB_DIR, "bm25_cache.pkl")
    if os.path.exists(bm25_cache_path):
        os.remove(bm25_cache_path)
        print("🧹 Đã dọn dẹp BM25 Cache cũ để ép cập nhật dữ liệu mới.")

    print("\n--- ✨ TẤT CẢ DỮ LIỆU ĐÃ ĐƯỢC ĐỒNG BỘ ---")

if __name__ == "__main__":
    main()
