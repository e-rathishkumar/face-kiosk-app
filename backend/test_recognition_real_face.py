import requests
url = "http://localhost:8001/recognition"

# I don't have a real face image, wait, I can download a sample face image!
import urllib.request
urllib.request.urlretrieve("https://raw.githubusercontent.com/opencv/opencv/master/samples/data/lena.jpg", "lena.jpg")

with open("lena.jpg", "rb") as f:
    files = {"image": ("lena.jpg", f, "image/jpeg")}
    data = {"kiosk_id": "kiosk123"}
    resp = requests.post(url, files=files, data=data)

print(resp.status_code)
print(resp.text)
