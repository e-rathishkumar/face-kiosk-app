import time
from sqlalchemy.orm import Session

from app.recognition.service import RecognitionService
from app.recognition.embedder import FaceEmbedder
from app.recognition.matcher import FaceMatcher

from app.repositories.employee_repository import EmployeeRepository
from app.services.file_service import FileService
from app.services.recognition_log_service import RecognitionLogService
from app.services.attendance_service import AttendanceService
from app.services.unrecognized_service import UnrecognizedService
from app.services.audit_service import AuditService

from app.core.constants import FACE_MATCH_THRESHOLD


class FaceRecognitionService:

    @staticmethod
    def recognize(db: Session, kiosk_id: str, image):
        t0 = time.time()
        
        image_bytes = image.file.read()
        t1 = time.time()

        embedding = FaceEmbedder.generate_embedding(image_bytes)
        t2 = time.time()

        match = FaceMatcher.find_best_match(db, embedding)
        t3 = time.time()
        
        image_path = FileService.save_face_image_bytes(image.filename, image_bytes)
        t4 = time.time()
        
        print(f"Timing - Read: {t1-t0:.3f}s, Embed: {t2-t1:.3f}s, Match: {t3-t2:.3f}s, Save: {t4-t3:.3f}s")

        timing_details = {
            "read_s": round(t1 - t0, 3),
            "embed_s": round(t2 - t1, 3),
            "match_s": round(t3 - t2, 3),
            "save_s": round(t4 - t3, 3),
            "total_s": round(t4 - t0, 3)
        }

        if not match:
            UnrecognizedService.create_entry(
                db=db,
                kiosk_id=kiosk_id,
                image_url=image_path,
                confidence_score=None
            )
            AuditService.log(
                db=db,
                action="FACE_NOT_RECOGNIZED",
                entity_type="RECOGNITION",
                entity_id=kiosk_id,
                new_value=image_path
            )
            return {
                "recognized": False,
                "reason": "NO_MATCH_FOUND",
                "unrecognized_entry_created": True,
                "timings": timing_details
            }

        employee_id, pose, distance = match
        employee = EmployeeRepository.get_by_id(db, employee_id)
        employee_name = f"{employee.first_name} {employee.last_name}"
        distance = float(distance)
        confidence_score = max(0.0, 1.0 - distance)

        if distance > FACE_MATCH_THRESHOLD:
            UnrecognizedService.create_entry(
                db=db,
                kiosk_id=kiosk_id,
                image_url=image_path,
                confidence_score=confidence_score
            )
            AuditService.log(
                db=db,
                action="THRESHOLD_FAILED",
                entity_type="RECOGNITION",
                entity_id=str(employee_id),
                new_value=str(confidence_score)
            )
            return {
                "recognized": False,
                "reason": "THRESHOLD_FAILED",
                "distance": distance,
                "confidence_score": confidence_score,
                "unrecognized_entry_created": True,
                "timings": timing_details
            }

        RecognitionLogService.create_log(
            db=db,
            employee_id=employee_id,
            kiosk_id=kiosk_id,
            confidence_score=confidence_score,
            image_url=image_path
        )

        AuditService.log(
            db=db,
            action="FACE_RECOGNIZED",
            entity_type="RECOGNITION",
            entity_id=str(employee_id),
            new_value=str(confidence_score)
        )
        
        has_active = AttendanceService.has_active_session(db, employee_id)

        return {
            "recognized": True,
            "employee_id": str(employee_id),
            "employee_name": employee_name,
            "pose": str(pose),
            "distance": distance,
            "confidence_score": confidence_score,
            "has_active_session": has_active,
            "timings": timing_details
        }
