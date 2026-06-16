import cv2


class FaceDetector:

    CASCADE_PATH = (
        cv2.data.haarcascades
        + "haarcascade_frontalface_default.xml"
    )

    detector = cv2.CascadeClassifier(
        CASCADE_PATH
    )

    @staticmethod
    def detect_faces(
        image_path: str
    ):
        image = cv2.imread(
            image_path
        )

        height, width = image.shape[:2]

        if width > 1920:
            scale = 1920 / width

            image = cv2.resize(
                image,
                (
                    int(width * scale),
                    int(height * scale)
                )
            )

        gray = cv2.cvtColor(
            image,
            cv2.COLOR_BGR2GRAY
        )

        faces = (
            FaceDetector.detector
            .detectMultiScale(
                gray,
                scaleFactor=1.2,
                minNeighbors=8,
                minSize=(200, 200)
            )
        )

        faces = sorted(
            faces,
            key=lambda f: f[2] * f[3],
            reverse=True
        )

        if len(faces) > 0:
            faces = [faces[0]]

        return faces
