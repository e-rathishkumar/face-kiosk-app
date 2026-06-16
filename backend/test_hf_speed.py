import time
import requests

try:
    with open("lena.jpg", "rb") as f:
        file_bytes = f.read()

    session = requests.Session()

    print("Warming up HF...")
    session.post(
        "https://rathishkumar-07-face-kiosk.hf.space/recognition",
        data={"kiosk_id": "00000000-0000-0000-0000-000000000000"},
        files={"image": ("lena.jpg", file_bytes, "image/jpeg")}
    )

    print("Running speed test...")
    start_time = time.time()
    response = session.post(
        "https://rathishkumar-07-face-kiosk.hf.space/recognition",
        data={"kiosk_id": "00000000-0000-0000-0000-000000000000"},
        files={"image": ("lena.jpg", file_bytes, "image/jpeg")}
    )
    end_time = time.time()
    
    print(f"Status Code: {response.status_code}")
    print(f"Time taken: {end_time - start_time:.4f} seconds")

except Exception as e:
    import traceback
    traceback.print_exc()
