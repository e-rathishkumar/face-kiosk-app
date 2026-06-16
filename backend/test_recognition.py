import time
import cv2
from app.recognition.insightface_service import InsightFaceService

print("Loading image...")
img = cv2.imread("dummy.jpg")
if img is None:
    import numpy as np
    img = np.zeros((480, 720, 3), dtype=np.uint8)

print("Starting prediction...")
start = time.time()
faces = InsightFaceService.app.get(img)
end = time.time()
print(f"Prediction took {end-start:.2f} seconds")
