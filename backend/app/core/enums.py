from enum import Enum


class UserRole(str, Enum):
    SUPER_ADMIN = "SUPER_ADMIN"
    ADMIN = "ADMIN"
    HR = "HR"
    EMPLOYEE = "EMPLOYEE"
    KIOSK = "KIOSK"


class AttendanceStatus(str, Enum):
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"


class CheckoutType(str, Enum):
    MANUAL = "MANUAL"
    AUTO = "AUTO"


class AlertSeverity(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class AlertType(str, Enum):
    LOW_BATTERY = "LOW_BATTERY"
    CRITICAL_BATTERY = "CRITICAL_BATTERY"
    HIGH_CPU = "HIGH_CPU"
    HIGH_TEMPERATURE = "HIGH_TEMPERATURE"
    LOW_STORAGE = "LOW_STORAGE"
    OFFLINE = "OFFLINE"


class UnrecognizedStatus(str, Enum):
    PENDING = "PENDING"
    VISITOR = "VISITOR"
    REGISTERED = "REGISTERED"
    IGNORED = "IGNORED"


class FacePose(str, Enum):
    FRONT = "FRONT"
    LEFT = "LEFT"
    RIGHT = "RIGHT"
    UP = "UP"
    DOWN = "DOWN"
    FRONT_LEFT = "FRONT_LEFT"
    FRONT_RIGHT = "FRONT_RIGHT"
