import time
import cv2
import numpy as np
from app.recognition.face_detector import FaceDetector

img = np.random.randint(0, 256, (1920, 1080, 3), dtype=np.uint8)
cv2.imwrite("noisy.jpg", img)

print("Starting FaceDetector.detect_faces...")
start = time.time()
FaceDetector.detect_faces("noisy.jpg")
end = time.time()
print(f"FaceDetector took {end-start:.2f} seconds")
