from backend.app.db.session import SessionLocal
from backend.app.models.user import User

db = SessionLocal()
users = db.query(User).all()
for u in users:
    print(f"Username: {u.username}, Role: {u.role}")
