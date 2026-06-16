from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
import time

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.employees import router as employee_router
from app.api.v1.endpoints.attendance import router as attendance_router
from app.api.v1.endpoints.kiosks import router as kiosk_router
from app.api.v1.endpoints.employee_faces import router as employee_face_router
from app.api.v1.endpoints.recognition import router as recognition_router
from app.api.v1.endpoints.unrecognized import router as unrecognized_router
from app.api.v1.endpoints.recognition_logs import router as recognition_logs_router
from app.api.v1.endpoints.dashboard import router as dashboard_router
from app.api.v1.endpoints.reports import router as reports_router
from app.api.v1.endpoints.alerts import router as alerts_router
from app.api.v1.endpoints.heartbeat import router as heartbeat_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.offline_monitor import router as offline_monitor_router
from app.api.v1.endpoints.audit_logs import router as audit_logs_router
from app.api.v1.endpoints.exports import router as exports_router
from app.api.v1.endpoints.report_history import (
    router as report_history_router
)
from app.api.v1.endpoints.report_schedules import (
    router as report_schedules_router
)
from app.api.v1.endpoints.report_scheduler import (
    router as report_scheduler_router
)

app = FastAPI(
    title="Face Recognition Kiosk API"
)

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/")
def root():
    return {
        "message": "Face Recognition Kiosk API"
    }

app.include_router(auth_router)
app.include_router(employee_router)
app.include_router(attendance_router)
app.include_router(kiosk_router)
app.include_router(employee_face_router)
app.include_router(recognition_router)
app.include_router(unrecognized_router)
app.include_router(recognition_logs_router)
app.include_router(dashboard_router)
app.include_router(reports_router)
app.include_router(alerts_router)
app.include_router(heartbeat_router)
app.include_router(health_router)
app.include_router(offline_monitor_router)
app.include_router(audit_logs_router)
app.include_router(exports_router)
app.include_router(report_history_router)
app.include_router(report_schedules_router)
app.include_router(report_scheduler_router)
