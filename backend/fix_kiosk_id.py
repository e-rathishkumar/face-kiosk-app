import sys
import uuid
from app.database.session import SessionLocal
from app.models.kiosk import Kiosk

db = SessionLocal()
kiosk_id = uuid.UUID('3a29bc44-6788-40e9-b4a9-d4ee456f166d')

kiosk = db.query(Kiosk).filter(Kiosk.id == kiosk_id).first()
if not kiosk:
    print("Creating dummy kiosk record...")
    kiosk = Kiosk(
        id=kiosk_id,
        kiosk_code="DEFAULT",
        name="Default Kiosk",
        location="Front Desk",
        secret_key="dummy_secret",
        is_active=True
    )
    db.add(kiosk)
    db.commit()
    print("Dummy kiosk created.")
else:
    print("Kiosk already exists.")
