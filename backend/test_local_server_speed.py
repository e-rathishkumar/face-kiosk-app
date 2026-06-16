import time
import requests

try:
    with open("lena.jpg", "rb") as f:
        file_bytes = f.read()

    session = requests.Session()

    print("Warming up local server...")
    session.post(
        "http://localhost:8001/recognition",
        data={"kiosk_id": "00000000-0000-0000-0000-000000000000"},
        files={"image": ("lena.jpg", file_bytes, "image/jpeg")}
    )

    print("Running speed test...")
    start_time = time.time()
    response = session.post(
        "http://localhost:8001/recognition",
        data={"kiosk_id": "00000000-0000-0000-0000-000000000000"},
        files={"image": ("lena.jpg", file_bytes, "image/jpeg")}
    )
    end_time = time.time()
    
    print(f"Status Code: {response.status_code}")
    print(f"X-Process-Time: {response.headers.get('X-Process-Time')}")
    print(f"Total Time taken: {end_time - start_time:.4f} seconds")

except Exception as e:
    import traceback
    traceback.print_exc()
