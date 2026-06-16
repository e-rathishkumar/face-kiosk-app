import time
import cv2
from app.recognition.insightface_service import InsightFaceService

img = cv2.imread("test_face.jpg")

print("Starting prediction on an actual face...")
start = time.time()
faces = InsightFaceService.app.get(img)
end = time.time()
print(f"Prediction took {end-start:.2f} seconds")
