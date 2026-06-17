from sqlalchemy.orm import Session

from app.repositories.employee_repository import (
    EmployeeRepository
)

from app.repositories.kiosk_repository import (
    KioskRepository
)

from app.repositories.attendance_repository import (
    AttendanceRepository
)

from app.repositories.recognition_log_repository import (
    RecognitionLogRepository
)

from app.repositories.unrecognized_repository import (
    UnrecognizedRepository
)


class DashboardService:

    @staticmethod
    def get_summary(
        db: Session
    ):
        return {
            "total_employees":
                EmployeeRepository.count(db),

            "active_attendance":
                AttendanceRepository.count_active(
                    db
                ),

            "total_kiosks":
                KioskRepository.count(db),

            "recognition_logs":
                RecognitionLogRepository.count(
                    db
                ),

            "pending_unrecognized":
                UnrecognizedRepository
                .count_pending(db)
        }

    @staticmethod
    def get_employee_summary(db: Session, employee_id: str):
        from datetime import datetime, timezone
        sessions = AttendanceRepository.get_employee_sessions(db, employee_id)
        
        now = datetime.now(timezone.utc)
        
        present_dates = []
        late_dates = []
        
        today_total_hours = 0.0
        
        for session in sessions:
            if not session.check_in_time:
                continue
                
            check_in_date = session.check_in_time.date()
            date_str = check_in_date.strftime("%d-%m-%Y")
            
            # Check if this month
            if check_in_date.month == now.month and check_in_date.year == now.year:
                # Naive late check (after 10:00 AM)
                if session.check_in_time.hour >= 10:
                    if date_str not in late_dates:
                        late_dates.append(date_str)
                else:
                    if date_str not in present_dates:
                        present_dates.append(date_str)
                        
            # Calculate today's hours
            if check_in_date == now.date():
                end_time = session.check_out_time if session.check_out_time else now.replace(tzinfo=None)
                diff = end_time - session.check_in_time
                today_total_hours += diff.total_seconds() / 3600.0

        # Since we don't have a formal calendar, absent days are just dummy for now or empty
        absent_dates = []

        return {
            "present_today": len(present_dates),
            "absent_today": len(absent_dates),
            "late_today": len(late_dates),
            "present_dates": present_dates,
            "absent_dates": absent_dates,
            "late_dates": late_dates,
            "total_hours_today": round(today_total_hours, 2)
        }

    @staticmethod
    def get_employee_activities(db: Session, employee_id: str):
        # Fetch attendance and logs
        sessions = AttendanceRepository.get_employee_sessions(db, employee_id)
        logs = RecognitionLogRepository.get_employee_logs(db, employee_id)
        
        activities = []
        
        for s in sessions:
            if s.check_in_time:
                activities.append({
                    "id": str(s.id) + "-in",
                    "type": "CHECK_IN",
                    "timestamp": s.check_in_time,
                    "status": s.status.value if hasattr(s.status, 'value') else str(s.status)
                })
            if s.check_out_time:
                activities.append({
                    "id": str(s.id) + "-out",
                    "type": "CHECK_OUT",
                    "timestamp": s.check_out_time,
                    "status": s.status.value if hasattr(s.status, 'value') else str(s.status)
                })
                
        for log in logs:
            activities.append({
                "id": str(log.id),
                "type": "DETECTION",
                "timestamp": log.event_time,
                "status": None
            })
            
        # Sort descending by timestamp
        activities.sort(key=lambda x: x["timestamp"], reverse=True)
        return activities
