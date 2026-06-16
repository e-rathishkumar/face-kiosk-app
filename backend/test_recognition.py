import sys
import os
import cv2
import numpy as np

# Create dummy image
img = np.zeros((200, 200, 3), dtype=np.uint8)
cv2.imwrite("test_face.jpg", img)

# We can't easily fake UploadFile without FastAPI, so let's use requests against the local server!
import requests
url = "http://localhost:8001/recognition"
with open("test_face.jpg", "rb") as f:
    files = {"image": ("test_face.jpg", f, "image/jpeg")}
    data = {"kiosk_id": "kiosk123"}
    resp = requests.post(url, files=files, data=data)

print(resp.status_code)
print(resp.text)
