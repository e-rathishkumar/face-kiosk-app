from app.services.offline_monitor_service import (
    OfflineMonitorService
)


def run_monitor(
    db
):
    return OfflineMonitorService.run(
        db
    )
