import os
from pathlib import Path
from dotenv import load_dotenv

current_file = Path(__file__).resolve()
PROJECT_ROOT = current_file.parent.parent.parent.parent
load_dotenv(PROJECT_ROOT / ".env")

class Config:
    VECTOR_DB_PATH = "/mnt/d/LibraryStorage/VectorData"
    EMBEDDING_MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
    LLM_MODEL = "gemini-robotics-er-1.6-preview"
    GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
    K_VECTOR = 5
    K_BM25 = 5
    ALPHA = 0.7 # Trọng số giữa Vector và BM25