from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.services.employee_service import EmployeeService
from app.schemas.employee_schema import EmployeeCreate
from app.core.config import settings

DATABASE_URL = "postgresql://face_kiosk_db_user:pNicdJb734WnXMDs7A3T7uU9nFkyIi0X@dpg-d8ok0m9o3t8c73dpap70-a.oregon-postgres.render.com:5432/face_kiosk_db?sslmode=require"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

try:
    data = EmployeeCreate(
        employee_code="E999",
        first_name="Test",
        last_name="User",
        email="test999@example.com",
        phone="1234567890",
        department="IT",
        designation="Tester"
    )
    EmployeeService.create_employee(db, data)
    print("Employee created successfully!")
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
