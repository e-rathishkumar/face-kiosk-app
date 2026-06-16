from app.database.session import engine

try:
    with engine.connect():
        print("DATABASE CONNECTION SUCCESSFUL")
except Exception as e:
    print(e)
