import psycopg2

conn = psycopg2.connect("postgresql://postgres:postgres@localhost:5432/face_kiosk")
cur = conn.cursor()
cur.execute("SELECT username, role, is_active FROM users LIMIT 10;")
for row in cur.fetchall():
    print(row)
cur.close()
conn.close()
