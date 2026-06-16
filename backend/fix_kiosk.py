from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.kiosk import Kiosk
import uuid

DATABASE_URL = "postgresql://face_kiosk_db_user:pNicdJb734WnXMDs7A3T7uU9nFkyIi0X@dpg-d8ok0m9o3t8c73dpap70-a.oregon-postgres.render.com:5432/face_kiosk_db?sslmode=require"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

kiosk_id = "00000000-0000-0000-0000-000000000000"
kiosk = db.query(Kiosk).filter(Kiosk.id == kiosk_id).first()
if not kiosk:
    kiosk = Kiosk(
        id=uuid.UUID(kiosk_id),
        kiosk_code='FALLBACK',
        name='Default Fallback Kiosk',
        location='Unknown',
        secret_key='fallback_secret',
        is_active=True
    )
    db.add(kiosk)
    db.commit()
    print("Default kiosk created!")
else:
    print("Default kiosk already exists!")
db.close()
