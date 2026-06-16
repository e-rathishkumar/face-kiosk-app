import psycopg2
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
hashed = pwd_context.hash('admin123')

conn = psycopg2.connect("postgresql://postgres:postgres@localhost:5432/face_kiosk")
cur = conn.cursor()
cur.execute("UPDATE users SET password_hash = %s WHERE username = 'admin'", (hashed,))
conn.commit()
cur.close()
conn.close()
print("Password updated to admin123 using argon2")
