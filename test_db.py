from sqlalchemy import create_engine
DATABASE_URL = "postgresql://face_kiosk_db_user:pNicdJb734WnXMDs7A3T7uU9nFkyIi0X@dpg-d8ok0m9o3t8c73dpap70-a.oregon-postgres.render.com:5432/face_kiosk_db?sslmode=require"
engine = create_engine(DATABASE_URL)
with engine.connect() as conn:
    res = conn.execute("SELECT * FROM alembic_version")
    for row in res:
        print(row)
