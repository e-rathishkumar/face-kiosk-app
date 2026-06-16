from pydantic import BaseModel


class OfflineMonitorResponse(BaseModel):
    kiosks_checked: int
    offline_alerts_created: int
