import os
from pathlib import Path
from dotenv import load_dotenv

current_file = Path(__file__).resolve()
PROJECT_ROOT = current_file.parent.parent.parent.parent
load_dotenv(PROJECT_ROOT / ".env")

class Config:
    
    VECTOR_DB_PATH = "/mnt/d/LibraryStorage/VectorData"
    EMBEDDING_MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
    LLM_MODEL = "gemini-2.5-flash"
    GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
    COHERE_API_KEY = os.getenv("COHERE_API_KEY")
    K_VECTOR = 15
    K_BM25 = 10
    ALPHA = 0.5 # Trọng số giữa Vector và BM25
