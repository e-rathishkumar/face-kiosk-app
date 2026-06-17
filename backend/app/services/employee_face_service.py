from sqlalchemy.orm import Session

from app.models.employee_face import EmployeeFace

from app.repositories.employee_face_repository import (
    EmployeeFaceRepository
)

from app.services.file_service import (
    FileService
)

from app.services.audit_service import (
    AuditService
)

from app.recognition.service import (
    RecognitionService
)

from app.recognition.embedder import (
    FaceEmbedder
)


class EmployeeFaceService:

    @staticmethod
    def upload_face(
        db: Session,
        employee_id,
        pose,
        image
    ):
        image_bytes = image.file.read()
        
        image_path = (
            FileService.save_face_image_bytes(
                image.filename,
                image_bytes
            )
        )

        # We skip Haar cascade validation because it fails on non-frontal faces.
        # FaceEmbedder will validate using InsightFace anyway.

        embedding = (
            FaceEmbedder.generate_embedding(
                image_bytes
            )
        )

        version = (
            EmployeeFaceRepository
            .count_by_employee(
                db,
                employee_id
            ) + 1
        )

        employee_face = EmployeeFace(
            employee_id=employee_id,
            image_url=image_path,
            pose=pose,
            embedding=embedding,
            version=version
        )

        employee_face = (
            EmployeeFaceRepository.create(
                db,
                employee_face
            )
        )

        AuditService.log(
            db=db,
            action="FACE_REGISTERED",
            entity_type="EMPLOYEE_FACE",
            entity_id=str(
                employee_face.id
            ),
            new_value=image_path
        )

        return employee_face

    @staticmethod
    def get_faces(
        db: Session,
        employee_id
    ):
        return (
            EmployeeFaceRepository
            .get_by_employee(
                db,
                employee_id
            )
        )
