import psycopg2

conn = psycopg2.connect("postgresql://postgres:postgres@localhost:5432/face_kiosk")
cur = conn.cursor()
cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='users';")
for row in cur.fetchall():
    print(row[0])
cur.close()
conn.close()
