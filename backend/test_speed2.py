import time
import cv2
from app.recognition.insightface_service import InsightFaceService

image = cv2.imread("lena.jpg")
InsightFaceService.app.get(image) # warmup

start = time.time()
faces = InsightFaceService.app.get(image)
end = time.time()

print(f"Time taken: {end - start:.4f} seconds")
