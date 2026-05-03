import os
import requests
from pathlib import Path
from langchain_community.document_loaders import PyMuPDFLoader
# Lưu ý: RecursiveCharacterTextSplitter thường từ langchain.text_splitter
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma

# --- CẤU HÌNH ---
PDF_FOLDER = "/home/quynhnhu/Projects/Library-Management_RAG/lib/assets/import_pdfs_cut"
CHECKLIST_FILE = "/home/quynhnhu/Projects/Library-Management_RAG/lib/assets/ingested_files.txt"
VECTOR_DB_DIR = "/mnt/d/LibraryStorage/VectorData"
RAILS_API_URL = "http://127.0.0.1:3000/api_rag/rag_data/metadata"

def load_books_metadata_from_rails():
    """Gọi API từ Rails để lấy thông tin sách"""
    print(f"📡 Đang kết nối với Rails API: {RAILS_API_URL}")
    try:
        response = requests.get(RAILS_API_URL, timeout=10)
        response.raise_for_status()
        json_data = response.json()
        
        if json_data.get("status") == "success":
            return {item['file_name']: item for item in json_data['data']}
        return {}
    except Exception as e:
        print(f"⚠️ Không thể lấy metadata từ Rails (Có thể server chưa bật): {e}")
        return {}

def main():
    print("\n--- 🔍 BẮT ĐẦU QUY TRÌNH NẠP DỮ LIỆU THÔNG MINH ---")
    
    # 0. Lấy Metadata từ Rails
    books_metadata = load_books_metadata_from_rails()
    if books_metadata:
        print(f"✅ Đã tải metadata cho {len(books_metadata)} đầu sách.")
    else:
        print("⚠️ Chế độ dự phòng: Tiếp tục nạp PDF không có metadata mở rộng.")

    # 1. Kiểm tra Checklist
    processed_files = []
    if os.path.exists(CHECKLIST_FILE):
        with open(CHECKLIST_FILE, "r", encoding="utf-8") as f:
            processed_files = f.read().splitlines()
    
    # 2. Khởi tạo Model & Vector DB
    print("⏳ Đang tải Local Embedding Model...")
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
    )
    vector_db = Chroma(persist_directory=VECTOR_DB_DIR, embedding_function=embeddings)
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)

    # 3. Quét thư mục tìm file mới
    files = [f for f in os.listdir(PDF_FOLDER) if f.endswith(".pdf")]
    new_files = [f for f in files if f not in processed_files]

    if not new_files:
        print("☕ Hệ thống đã đồng bộ hoàn toàn!")
        return

    print(f"🚀 Tìm thấy {len(new_files)} file mới cần xử lý.")

    # Vòng lặp phải được thụt lề vào bên trong hàm main
    for filename in sorted(new_files):
        file_path = os.path.join(PDF_FOLDER, filename)
        print(f"\n📖 Đang xử lý: {filename}")
        
        meta_info = books_metadata.get(filename, {})
        
        try:
            loader = PyMuPDFLoader(file_path)
            pages = loader.load()
            
            if not pages:
                continue

            # Gán metadata chi tiết vào từng trang
            for page in pages:
                page.metadata["source"] = filename
                if meta_info:
                    page.metadata.update({
                        "book_id": meta_info.get("id"),
                        "title": meta_info.get("title"),
                        "author": meta_info.get("author"),
                        "publisher": meta_info.get("publisher"),
                        "year": meta_info.get("publication_year"),
                        "categories": meta_info.get("categories"),
                        "description": meta_info.get("description"),
                        "available": meta_info.get("available_quantity"),
                        "total": meta_info.get("total_quantity"),
                        "rating": meta_info.get("average_rating"),
                        "borrow_count": meta_info.get("borrow_count"),
                        "full_info": meta_info.get("full_metadata_text")
                    })
            
            chunks = text_splitter.split_documents(pages)
            print(f"  -> [LƯU Ý] Đã nhúng Full Metadata vào {len(chunks)} chunks.")
            
            vector_db.add_documents(chunks)
            
            # Cập nhật checklist
            with open(CHECKLIST_FILE, "a", encoding="utf-8") as f:
                f.write(filename + "\n")
            
            print(f"✅ HOÀN THÀNH: {filename}")

        except Exception as e:
            print(f"❌ LỖI tại file {filename}: {str(e)}")

    print("\n--- ✨ TẤT CẢ DỮ LIỆU ĐÃ ĐƯỢC ĐỒNG BỘ VỚI RAILS ---")

if __name__ == "__main__":
    main()