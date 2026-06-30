import os
import requests
import hashlib
from pathlib import Path
from langchain_community.document_loaders import PyMuPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_core.documents import Document
from config import Config

# Bỏ cấu hình CHECKLIST_FILE
PDF_FOLDER = "/home/quynhnhu/Projects/Library-Management_RAG/lib/assets/import_pdfs_cut"
VECTOR_DB_DIR = Config.VECTOR_DB_PATH
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
        model_name=Config.EMBEDDING_MODEL
    )
    vector_db = Chroma(persist_directory=VECTOR_DB_DIR, embedding_function=embeddings)
    
    # 1. Cấu hình splitters phân cấp (Hierarchical Chunking)
    parent_splitter = RecursiveCharacterTextSplitter(chunk_size=2000, chunk_overlap=400)
    child_splitter = RecursiveCharacterTextSplitter(chunk_size=400, chunk_overlap=50)

    files = [f for f in os.listdir(PDF_FOLDER) if f.endswith(".pdf")]
    
    if not files:
        print("☕ Không tìm thấy file PDF nào trong thư mục!")
        return

    print(f"🚀 Xử lý nạp / cập nhật (Upsert) {len(files)} file PDF.")

    for filename in sorted(files):
        file_path = os.path.join(PDF_FOLDER, filename)
        print(f"\n📖 Đang xử lý: {filename}")
        
        meta_info = books_metadata.get(filename, {})
        book_id = meta_info.get("id")
        title = meta_info.get("title", filename)
        author = meta_info.get("author", "Chưa rõ tác giả")
        publisher = meta_info.get("publisher", "Chưa rõ nhà xuất bản")
        publication_year = meta_info.get("publication_year", "")
        categories = meta_info.get("categories", "Chưa phân loại")
        description = meta_info.get("description", "Không có mô tả.")
        
        try:
            loader = PyMuPDFLoader(file_path)
            pages = loader.load()
            
            if not pages:
                continue

            for page in pages:
                page.metadata["source"] = filename
                if meta_info:
                    page.metadata.update({
                        "book_id": book_id,
                        "title": title,
                        "author": author,
                        "publisher": publisher
                    })
            
            documents_to_add = []
            chunk_ids = []

            # 2. Tạo Chunk Tóm tắt (Summary Chunk)
            summary_content = f"Tóm tắt & Giới thiệu sách: {title}\nTác giả: {author}\nNhà xuất bản: {publisher} ({publication_year})\nThể loại: {categories}\nMô tả nội dung: {description}"
            summary_doc = Document(
                page_content=summary_content,
                metadata={
                    "source": filename,
                    "type": "book_summary",
                    "title": title,
                    "author": author,
                    "publisher": publisher,
                    "book_id": book_id
                }
            )
            summary_id = hashlib.md5(f"{filename}_summary".encode("utf-8")).hexdigest()
            documents_to_add.append(summary_doc)
            chunk_ids.append(summary_id)

            # 3. Phân mảnh Parent-Child
            parent_chunks = parent_splitter.split_documents(pages)
            for i, parent_chunk in enumerate(parent_chunks):
                parent_id = hashlib.md5(f"{filename}_parent_{i}".encode("utf-8")).hexdigest()
                
                # 3.1. Parent Chunk
                parent_chunk.metadata.update({
                    "type": "parent",
                    "parent_id": parent_id
                })
                documents_to_add.append(parent_chunk)
                chunk_ids.append(parent_id)

                # 3.2. Child Chunks
                child_docs = child_splitter.split_documents([parent_chunk])
                for j, child_doc in enumerate(child_docs):
                    child_id = hashlib.md5(f"{filename}_child_{i}_{j}".encode("utf-8")).hexdigest()
                    child_doc.metadata.update({
                        "type": "child",
                        "parent_id": parent_id
                    })
                    documents_to_add.append(child_doc)
                    chunk_ids.append(child_id)
            
            print(f"  -> Đang đẩy {len(documents_to_add)} chunks (1 Summary + {len(parent_chunks)} Parents + {len(documents_to_add) - 1 - len(parent_chunks)} Children) vào ChromaDB.")
            # Ghi đè tự động theo ids
            vector_db.add_documents(documents=documents_to_add, ids=chunk_ids)
            
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
