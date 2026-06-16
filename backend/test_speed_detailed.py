import time
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.services.recognition_service import FaceRecognitionService
from app.services.file_service import FileService
from app.recognition.embedder import FaceEmbedder
from app.recognition.matcher import FaceMatcher

DATABASE_URL = "postgresql://face_kiosk_db_user:pNicdJb734WnXMDs7A3T7uU9nFkyIi0X@dpg-d8ok0m9o3t8c73dpap70-a.oregon-postgres.render.com:5432/face_kiosk_db?sslmode=require"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

import io
class DummyUploadFile:
    def __init__(self, filename, file_obj):
        self.filename = filename
        self.file = file_obj

try:
    with open("lena.jpg", "rb") as f:
        file_bytes = f.read()
    
    upload_file = DummyUploadFile("lena.jpg", io.BytesIO(file_bytes))
    
    # Warmup
    FaceRecognitionService.recognize(db, "00000000-0000-0000-0000-000000000000", upload_file)
    upload_file.file.seek(0)
    
    t0 = time.time()
    image_path = FileService.save_face_image(upload_file)
    t1 = time.time()
    embedding = FaceEmbedder.generate_embedding(image_path)
    t2 = time.time()
    match = FaceMatcher.find_best_match(db, embedding)
    t3 = time.time()
    
    print(f"File Save: {t1-t0:.4f}s")
    print(f"Embedding: {t2-t1:.4f}s")
    print(f"DB Match: {t3-t2:.4f}s")
    
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
