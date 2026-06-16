from app.database.session import engine
from app.database.base import Base
# Import all models to ensure they are registered
from app.models.kiosk import Kiosk
from app.models.kiosk_metrics import KioskMetrics
from app.models.kiosk_heartbeat import KioskHeartbeat
from app.models.kiosk_alert import KioskAlert

print("Creating tables...")
Base.metadata.create_all(bind=engine)
print("Done.")
