from pathlib import Path
from uuid import uuid4


class FileService:

    FACE_UPLOAD_DIR = Path(
        "uploads/faces"
    )

    FACE_UPLOAD_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    @staticmethod
    def save_face_image(file):

        extension = (
            file.filename.split(".")[-1]
        )

        filename = (
            f"{uuid4()}.{extension}"
        )

        filepath = (
            FileService.FACE_UPLOAD_DIR
            / filename
        )

        with open(
            filepath,
            "wb"
        ) as buffer:
            buffer.write(
                file.file.read()
            )

        return str(filepath)
