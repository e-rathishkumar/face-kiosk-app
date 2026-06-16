from app.recognition.face_detector import FaceDetector

image_path = "uploads/faces/bfdf94d9-342e-4e23-af84-3ec5764a0a62.png"

faces = FaceDetector.detect_faces(image_path)

print("Faces found:", len(faces))

for i, (x, y, w, h) in enumerate(faces):
    print(
        f"Face {i+1}: "
        f"x={x}, y={y}, w={w}, h={h}"
    )
