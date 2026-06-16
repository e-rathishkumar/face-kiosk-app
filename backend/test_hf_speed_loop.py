import time
import requests

try:
    with open("lena.jpg", "rb") as f:
        file_bytes = f.read()

    session = requests.Session()
    
    print("Waiting for HF to deploy the new commit with 'timings' in the response...")
    while True:
        response = session.post(
            "https://rathishkumar-07-face-kiosk.hf.space/recognition",
            data={"kiosk_id": "00000000-0000-0000-0000-000000000000"},
            files={"image": ("lena.jpg", file_bytes, "image/jpeg")}
        )
        
        if response.status_code == 200:
            data = response.json()
            if "timings" in data:
                print(f"Deployment complete! X-Process-Time: {response.headers.get('X-Process-Time')}")
                print(f"Timings: {data['timings']}")
                break
            else:
                print("Still running old commit, sleeping 5 seconds...")
        else:
            print(f"Error {response.status_code}, sleeping 5 seconds...")
            
        time.sleep(5)

except Exception as e:
    import traceback
    traceback.print_exc()
