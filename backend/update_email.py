import psycopg2

conn = psycopg2.connect("postgresql://postgres:postgres@localhost:5432/face_kiosk")
cur = conn.cursor()
cur.execute("UPDATE users SET email = 'admin@kiosk.com' WHERE username = 'admin'")
conn.commit()
cur.close()
conn.close()
print("Admin email updated")
