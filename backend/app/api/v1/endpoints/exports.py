from fastapi import APIRouter
from fastapi import Depends

from fastapi.responses import FileResponse

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.services.export_service import (
    ExportService
)

router = APIRouter(
    prefix="/exports",
    tags=["Exports"]
)


@router.get("/attendance/csv")
def attendance_csv(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_attendance_csv(db)
    )

    return FileResponse(
        path=file_path,
        filename="attendance_report.csv"
    )


@router.get("/attendance/xlsx")
def attendance_xlsx(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_attendance_xlsx(db)
    )

    return FileResponse(
        path=file_path,
        filename="attendance_report.xlsx"
    )


@router.get("/recognition/csv")
def recognition_csv(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_recognition_csv(db)
    )

    return FileResponse(
        path=file_path,
        filename="recognition_report.csv"
    )


@router.get("/recognition/xlsx")
def recognition_xlsx(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_recognition_xlsx(db)
    )

    return FileResponse(
        path=file_path,
        filename="recognition_report.xlsx"
    )


@router.get("/unrecognized/csv")
def unrecognized_csv(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_unrecognized_csv(db)
    )

    return FileResponse(
        path=file_path,
        filename="unrecognized_report.csv"
    )


@router.get("/unrecognized/xlsx")
def unrecognized_xlsx(
    db: Session = Depends(get_db)
):
    file_path = (
        ExportService.export_unrecognized_xlsx(db)
    )

    return FileResponse(
        path=file_path,
        filename="unrecognized_report.xlsx"
    )
