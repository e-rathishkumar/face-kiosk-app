import time
import cv2
import numpy as np
from app.recognition.insightface_service import InsightFaceService

print("Loading image...")
# create a noisy image which takes longer to process
img = np.random.randint(0, 256, (1080, 1920, 3), dtype=np.uint8)

print("Starting prediction...")
start = time.time()
faces = InsightFaceService.app.get(img)
end = time.time()
print(f"Prediction took {end-start:.2f} seconds")
