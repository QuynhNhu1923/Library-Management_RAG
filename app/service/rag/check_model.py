import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv() # Đọc API Key từ file .env
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

print("Danh sách các model khả dụng cho API Key của bạn:")
for m in genai.list_models():
    if "generateContent" in m.supported_generation_methods:
        print(f"👉 {m.name.replace('models/', '')}")