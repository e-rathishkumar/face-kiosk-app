from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.services.recognition_service import FaceRecognitionService
from app.core.config import settings

DATABASE_URL = "postgresql://face_kiosk_db_user:pNicdJb734WnXMDs7A3T7uU9nFkyIi0X@dpg-d8ok0m9o3t8c73dpap70-a.oregon-postgres.render.com:5432/face_kiosk_db?sslmode=require"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
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
    result = FaceRecognitionService.recognize(db, "00000000-0000-0000-0000-000000000000", upload_file)
    print("Result:", result)
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
