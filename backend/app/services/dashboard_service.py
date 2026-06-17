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
        from datetime import datetime, timedelta, timezone
        sessions = AttendanceRepository.get_employee_sessions(db, employee_id)
        
        now = datetime.now(timezone.utc)
        now_naive = datetime.utcnow()
        
        daily_status = {}
        today_total_hours = 0.0
        
        for session in sessions:
            if not session.check_in_time:
                continue
                
            check_in_date = session.check_in_time.date()
            date_str = check_in_date.strftime("%d-%m-%Y")
            
            # Check if this month
            if check_in_date.month == now.month and check_in_date.year == now.year:
                # If they checked in before 10 AM, they are present. Otherwise late.
                # Since multiple sessions can exist in a day, Present overrides Late.
                is_late = session.check_in_time.hour >= 10
                
                if date_str not in daily_status:
                    daily_status[date_str] = "LATE" if is_late else "PRESENT"
                else:
                    # Upgrade to PRESENT if an earlier session was on time
                    if not is_late:
                        daily_status[date_str] = "PRESENT"
                        
            # Calculate today's hours.
            if check_in_date == now_naive.date():
                end_time = session.check_out_time if session.check_out_time else now_naive
                diff = end_time - session.check_in_time
                today_total_hours += diff.total_seconds() / 3600.0

        present_dates = [d for d, s in daily_status.items() if s == "PRESENT"]
        late_dates = [d for d, s in daily_status.items() if s == "LATE"]
        
        # Calculate absent dates (weekdays up to today that are neither present nor late)
        absent_dates = []
        # Start from the 1st of the month
        start_date = now_naive.date().replace(day=1)
        current_date = start_date
        
        while current_date <= now_naive.date():
            # weekday() 0-4 are Monday-Friday
            if current_date.weekday() < 5:
                d_str = current_date.strftime("%d-%m-%Y")
                if d_str not in daily_status:
                    absent_dates.append(d_str)
            current_date += timedelta(days=1)
            
        # Reverse all lists to show newest dates first
        present_dates.reverse()
        late_dates.reverse()
        absent_dates.reverse()

        return {
            "present_today": len(present_dates),
            "absent_today": len(absent_dates),
            "late_today": len(late_dates),
            "present_dates": present_dates,
            "absent_dates": absent_dates,
            "late_dates": late_dates,
            "total_hours_today": round(today_total_hours, 2) if today_total_hours > 0 else 0.0
        }

    @staticmethod
    def get_employee_activities(db: Session, employee_id: str):
        # Fetch attendance and logs
        sessions = AttendanceRepository.get_employee_sessions(db, employee_id)
        logs = RecognitionLogRepository.get_by_employee(db, employee_id)
        
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
