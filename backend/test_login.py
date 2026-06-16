from app.db.database import SessionLocal
from app.services.auth_service import AuthService

db = SessionLocal()
try:
    result = AuthService.login(db, "admin", "admin123")
    print("Login result:", result)
except Exception as e:
    import traceback
    traceback.print_exc()
