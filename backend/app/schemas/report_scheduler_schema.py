from pydantic import BaseModel


class ReportSchedulerResponse(
    BaseModel
):
    schedules_checked: int
    executed: int
