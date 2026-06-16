Face Recognition Kiosk System
Software Requirements Specification (SRS)
Solution Architecture Document (SAD)
Technical Design Document (TDD)
Version: 1.0
Status: Approved for Development

1. Executive Summary
1.1 Purpose
The Face Recognition Kiosk System is a production-grade employee attendance and presence management platform designed to automate employee check-in, checkout, attendance tracking, and workplace presence monitoring using facial recognition technology.
The system eliminates manual attendance processes and provides real-time visibility into employee attendance, kiosk health, recognition events, and operational insights.
The platform is designed to support:
* Multiple kiosks
* 1000+ employees
* Employee self-service
* Administrative monitoring
* Real-time attendance tracking
* Secure facial recognition
* Enterprise-grade security

2. Vision
Build a highly reliable, low-latency, secure, and scalable facial recognition attendance platform that:
* Automatically identifies employees.
* Reduces attendance fraud.
* Simplifies employee check-in and checkout.
* Provides operational visibility.
* Supports long-term scalability.
* Remains easy to maintain.

3. Business Objectives
The primary business objectives are:
BO-01
Automate attendance recording.
BO-02
Reduce manual HR effort.
BO-03
Improve attendance accuracy.
BO-04
Track employee presence in real time.
BO-05
Provide auditability.
BO-06
Provide centralized kiosk management.
BO-07
Provide health monitoring for deployed kiosks.
BO-08
Generate downloadable attendance reports.
BO-09
Support future expansion.

4. Project Scope
Included in V1
Attendance Management
* Automatic check-in
* Manual checkout
* Auto checkout fallback
* Work hour calculation
Face Recognition
* Face detection
* Face recognition
* Recognition logging
* Unknown face handling
Kiosk Management
* Kiosk registration
* Kiosk monitoring
* Kiosk authentication
Employee Application
* Dashboard
* Attendance history
* Employee profile
Admin Portal
* Employee management
* Logs management
* Kiosk management
* Reports management
Security
* JWT Authentication
* RBAC
* HTTPS
* Audit logs

Excluded from V1
* Payroll integration
* Leave management
* Shift management
* Visitor management
* Remote kiosk updates
* Remote kiosk restart
* Advanced analytics

5. Stakeholders
Super Admin
Responsible for:
* System configuration
* User management
* Kiosk management

Admin
Responsible for:
* Employee management
* Attendance monitoring
* Reports

HR
Responsible for:
* Attendance review
* Employee records
* Attendance reports

Employee
Responsible for:
* Attendance tracking
* Viewing history

Kiosk
Responsible for:
* Employee recognition
* Attendance capture

6. User Roles
SUPER_ADMIN
ADMIN
HR
EMPLOYEE
KIOSK

7. Functional Requirements
FR-01 Employee Recognition
The system shall identify employees using facial recognition.

FR-02 Automatic Check-In
The system shall automatically create a check-in record when an employee is recognized for the first time during a day.

FR-03 Manual Checkout
The system shall allow employees to checkout using the kiosk checkout mode.

FR-04 Recognition Logging
The system shall record all recognition events separately from attendance records.

FR-05 Auto Checkout
The system shall automatically close attendance sessions using the latest recognition timestamp if manual checkout is missing.

FR-06 Unrecognized Entry Handling
The system shall store unknown faces for administrative review.

FR-07 Kiosk Health Monitoring
The system shall monitor kiosk battery, CPU, memory, storage, temperature, and connectivity.

FR-08 Reports
The system shall provide downloadable attendance and operational reports.

FR-09 Email Reports
The system shall support scheduled report delivery to administrator email addresses.

FR-10 Audit Logging
The system shall record all critical actions.

8. Non-Functional Requirements
Performance
Face recognition response time:
Target:
< 1000 ms
Preferred:
< 500 ms

Attendance API Response:
< 500 ms

Dashboard API Response:
< 1000 ms

Availability
Target uptime:
99.5%

Scalability
Support:
* 1000+ employees
* 10+ kiosks
* 100,000+ recognition logs

Security
Mandatory:
* JWT Authentication
* RBAC
* HTTPS
* AES-256 Encryption
* Argon2 Password Hashing

Reliability
No attendance data loss.
No duplicate active attendance sessions.

Maintainability
Feature-based frontend structure.
Layered backend architecture.
Repository pattern.

9. Business Workflow
Employee Check-In
Employee Arrives↓Face Detected↓Employee Recognized↓No Active Session↓Automatic Check-In↓Attendance Session Created↓Welcome Screen↓Detection Mode

Recognition During Day
Employee Recognized↓Attendance Already Active↓Recognition Log Created↓Update Last Seen↓Continue Detection

Employee Checkout
Employee Clicks Checkout↓Checkout Mode↓Recognition↓Manual Checkout↓Close Session↓Checkout Success Screen

Auto Checkout
Scheduler Runs↓Find Active Sessions↓Find Last Recognition↓Close Session↓Checkout Type = AUTO

10. Attendance Rules
Rule 1
Only one active attendance session per employee.
Rule 2
First recognition creates attendance session.
Rule 3
Recognition logs do not modify attendance.
Rule 4
Manual checkout closes session.
Rule 5
Auto checkout uses latest recognition timestamp.
Rule 6
Work hours:
Checkout Time - Check-In Time

11. Recognition Rules
Recognition Cooldown:
60 Seconds
Same employee recognized within 60 seconds:
Ignored
Different employee:
Processed immediately

12. Unrecognized Entry Rules
Unknown faces shall be stored with:
* Original Image
* Face Crop
* Timestamp
* Kiosk ID
Admin actions:
* Ignore
* Visitor
* Register Employee

Solution Architecture Document (SAD)
Part 2 – System Architecture & Solution Design

13. Solution Architecture Overview
Architecture Style
The system follows a distributed multi-application architecture.
Components:
Flutter Kiosk App
        │
        │ HTTPS + JWT
        ▼
FastAPI Backend
        │
 ┌──────┼────────┐
 ▼      ▼        ▼

PostgreSQL  Redis  File Storage
(pgvector)
        │
        ▼
React Admin Portal

        │

Flutter Employee App

Architectural Principles
AP-01
Single source of truth.
All business logic is controlled by FastAPI.

AP-02
Thin clients.
Business rules must remain in backend.
Flutter and React should only display information.

AP-03
Stateless APIs.
Every request must be authenticated.

AP-04
Scalable recognition architecture.
Recognition engine must be independent from UI.

AP-05
Security first.
Every component must use JWT authentication and HTTPS.

14. High-Level System Flow
Employee
    │
    ▼
Kiosk Camera
    │
    ▼
Motion Detection
    │
    ▼
Face Recognition
    │
    ▼
Recognition Result
    │
 ┌──┴──┐
 ▼     ▼

Known  Unknown
 │       │
 ▼       ▼

Attendance  Unrecognized Entry
 │
 ▼

Backend API
 │
 ▼

Database
 │
 ▼

Employee App
Admin Portal

15. Kiosk Architecture
Purpose
The kiosk application is responsible for:
* Detecting employee presence.
* Capturing frames.
* Running recognition.
* Recording attendance.
* Monitoring device health.

Kiosk Components
Kiosk App

├── Login Module
├── Detection Module
├── Recognition Module
├── Checkout Module
├── Health Monitor
├── Heartbeat Service
├── Secure Storage
└── API Client

Kiosk Workflow
App Launch
↓
Kiosk Login
↓
Token Validation
↓
Detection Screen
↓
Recognition
↓
Attendance Processing
↓
Continue Detection

Kiosk States
APP_START

LOGIN

DETECTION

RECOGNIZING

CHECKIN_SUCCESS

CHECKOUT_MODE

CHECKOUT_SUCCESS

SETTINGS

Kiosk Login
Purpose:
Authenticate kiosk before attendance operations.
Stored Securely:
Access Token

Refresh Token

Kiosk ID

Kiosk Secret

Detection Module
Responsibilities:
* Camera Preview
* Motion Detection
* Frame Capture
* Focus Area Validation

Recognition Module
Responsibilities:
* Face Detection
* Embedding Generation
* Matching
* Confidence Calculation

Checkout Module
Responsibilities:
* Checkout Mode Activation
* Employee Verification
* Session Closure

Heartbeat Module
Interval:
60 Seconds
Sends:
Battery
CPU
Memory
Temperature
Storage
Network
App Version
Device Model

16. Employee Mobile App Architecture
Purpose
Allow employees to monitor attendance information.

Modules
Authentication

Dashboard

Attendance History

Profile

Settings

Dashboard
Displays:
Today's Check-In

Today's Check-Out

Current Work Hours

Attendance Status

Attendance History
Displays:
Date

Check-In

Check-Out

Hours

Checkout Type

Profile
Displays:
Employee Information

Department

Designation

Employee Code

Employee App Flow
Login
↓
Dashboard
↓
History
↓
Profile

17. Admin Portal Architecture
Purpose
Provide complete administration and monitoring capabilities.

Final Admin Menu
Dashboard

Employees

Logs

Unrecognized Entries

Kiosks

Reports

Settings

Dashboard Module
Displays:
Total Employees

Today's Check-Ins

Active Sessions

Unrecognized Entries

Online Kiosks

Employees Module
Features:
Add Employee

Edit Employee

Deactivate Employee

Register Face

Update Face

Logs Module
Contains:
Attendance Logs

Recognition Logs

Unrecognized Entries Module
Contains:
Pending Entries

Reviewed Entries
Actions:
Ignore

Mark Visitor

Register Employee

Kiosks Module
Contains:
Kiosk Registry
Register Kiosk

Edit Kiosk

Deactivate Kiosk

Kiosk Health
Battery

CPU

Memory

Temperature

Storage

Network

Heartbeat

Kiosk Alerts
Low Battery

Critical Battery

High CPU

High Temperature

Low Storage

Offline

Reports Module
Attendance Reports
Filters:
Date Range

Employee

Department

Work Hours Reports
Displays:
Check-In

Check-Out

Hours Worked

Recognition Reports
Displays:
Employee

Timestamp

Kiosk

Confidence

Unrecognized Reports
Displays:
Date

Kiosk

Status

Kiosk Health Reports
Displays:
Health Metrics

Alert History

Export Formats
Excel (.xlsx)

PDF

CSV

Email Reports
Supports:
Manual Email

Daily Schedule

Weekly Schedule

Monthly Schedule
Multiple recipients supported.

18. Face Recognition Architecture
Technology
InsightFace

Recognition Pipeline
Motion Detected
↓
Capture Frames
↓
Quality Check
↓
Best Frame Selection
↓
Face Detection
↓
Embedding Generation
↓
Vector Matching
↓
Recognition Result

Matching Engine
pgvector

Recognition Result
Known Employee
Employee ID

Confidence Score

Timestamp

Kiosk ID
Attendance processing begins.

Unknown Face
Store Image

Store Face Crop

Create Unrecognized Entry

Recognition Threshold
Configurable through settings.
Example:
0.75
Can be adjusted without code changes.

Performance Target
Recognition Time:
Preferred:
< 500 ms
Maximum:
< 1000 ms

19. Security Architecture
Authentication Layer
JWT Authentication.

Access Token
Lifetime:
15 Minutes

Refresh Token
Lifetime:
7 Days

Authorization Layer
Role-Based Access Control (RBAC)
Roles:
SUPER_ADMIN

ADMIN

HR

EMPLOYEE

KIOSK

Password Security
Algorithm:
Argon2
Passwords never stored in plain text.

Transport Security
Mandatory:
HTTPS
TLS 1.2+

Data Encryption
Algorithm:
AES-256
Encrypted Fields:
Email

Phone Number

Future Sensitive Fields

Image Protection
Employee and unrecognized images:
JWT Protected Access Only

Audit Logging
Every critical action is logged.
Examples:
Login

Logout

Employee Update

Face Registration

Attendance Modification

Settings Change

Rate Limiting
Authentication APIs:
5 Failed Attempts
↓
Temporary Lock

20. Infrastructure Architecture
Production Environment
Ubuntu Server

Reverse Proxy
Nginx

Application Layer
FastAPI

Database Layer
PostgreSQL

pgvector

Cache Layer
Redis

Containerization
Docker

Deployment Architecture
Internet
   │
   ▼

Nginx
   │
   ▼

FastAPI
   │
 ┌─┴───────┐

 ▼         ▼

PostgreSQL Redis
(pgvector)

Recommended Production Configuration
Minimum:
2 vCPU

4 GB RAM

80 GB SSD
Recommended:
4 vCPU

8 GB RAM

120+ GB SSD
for multiple kiosks and 1000+ employees.

Monitoring Requirements
Monitor:
CPU

Memory

Disk

Database

API Response Time

Kiosk Heartbeats

Recognition Latency

Backup Strategy
Database Backup:
Daily
Retention:
30 Days

Disaster Recovery Goal
RPO:
24 Hours
RTO:
4 Hours


Database Design Specification (DDS)
Part 3 – Database Architecture & Schema Design

21. Database Overview
Purpose
The database is the central source of truth for:
* Employee Information
* Facial Embeddings
* Attendance Sessions
* Recognition Logs
* Unrecognized Entries
* Kiosk Information
* Health Monitoring
* Alerts
* Reports
* Audit Logs

Database Technology
PostgreSQL
Extensions:
pgvector
uuid-ossp

22. Database Design Principles
Principle 1
Use UUID as primary key.
Reason:
Distributed Systems
Security
Scalability

Principle 2
Use soft deletion where appropriate.

Principle 3
Store audit timestamps everywhere.
created_at

updated_at

Principle 4
Store facial embeddings separately.
Never store face data directly inside employee table.

Principle 5
Attendance sessions and recognition logs are separate.

23. Enums
UserRole
SUPER_ADMIN

ADMIN

HR

EMPLOYEE

KIOSK

AttendanceStatus
ACTIVE

COMPLETED

CheckoutType
MANUAL

AUTO

AlertSeverity
LOW

MEDIUM

HIGH

CRITICAL

AlertType
LOW_BATTERY

CRITICAL_BATTERY

HIGH_CPU

HIGH_TEMPERATURE

LOW_STORAGE

OFFLINE

UnrecognizedStatus
PENDING

VISITOR

REGISTERED

IGNORED

24. Core Tables

users
Purpose:
Authentication and authorization.
Fields:
id UUID PK

username

email

password_hash

role

is_active

last_login

created_at

updated_at

Indexes:
email

username

employees
Purpose:
Employee master information.
Fields:
id UUID PK

employee_code

first_name

last_name

email

phone

department

designation

joining_date

is_active

created_at

updated_at

Constraints:
employee_code UNIQUE

Indexes:
employee_code

department

employee_faces
Purpose:
Store facial recognition data.
Fields:
id UUID PK

employee_id FK

embedding VECTOR

image_url

version

created_at

Relationship:
Employee
  └── Multiple Face Records

Embedding Type:
VECTOR(512)
Depends on final InsightFace model.

attendance_sessions
Purpose:
Track employee attendance.
Fields:
id UUID PK

employee_id FK

kiosk_id FK

check_in_time

check_out_time

checkout_type

status

created_at

updated_at

Business Rules:
Only One Active Session Per Employee

Indexes:
employee_id

status

check_in_time

recognition_logs
Purpose:
Store every successful recognition.
Fields:
id UUID PK

employee_id FK

kiosk_id FK

confidence_score

event_time

image_url

created_at

Example:
09:00

11:15

13:30

17:45

Indexes:
employee_id

event_time

kiosk_id

unrecognized_entries
Purpose:
Store unknown faces.
Fields:
id UUID PK

kiosk_id FK

image_url

face_crop_url

confidence_score

status

reviewed_by

reviewed_at

remarks

created_at

Workflow:
Unknown Face
↓
Stored
↓
Admin Review

Indexes:
status

created_at

kiosks
Purpose:
Store kiosk information.
Fields:
id UUID PK

kiosk_code

name

location

secret_key

is_active

created_at

updated_at

Examples:
MAIN_ENTRANCE

BLOCK_A

PARKING_GATE

kiosk_heartbeats
Purpose:
Store device health data.
Fields:
id UUID PK

kiosk_id FK

battery_level

cpu_usage

memory_usage

temperature

storage_total

storage_available

network_strength

device_model

app_version

heartbeat_time

Heartbeat Interval:
60 Seconds

Indexes:
kiosk_id

heartbeat_time

kiosk_alerts
Purpose:
Store health alerts.
Fields:
id UUID PK

kiosk_id FK

alert_type

severity

message

is_resolved

resolved_by

resolved_at

created_at

Examples:
Low Battery

Offline

High Temperature

Indexes:
alert_type

severity

is_resolved

settings
Purpose:
Global configuration.
Fields:
id UUID PK

setting_key

setting_value

updated_by

updated_at

Examples:
recognition_threshold

cooldown_seconds

auto_checkout_enabled

audit_logs
Purpose:
Track all sensitive actions.
Fields:
id UUID PK

user_id FK

action

entity_type

entity_id

old_value

new_value

ip_address

created_at

Examples:
Employee Updated

Face Registered

Kiosk Added

Settings Changed

report_schedules
Purpose:
Scheduled email reports.
Fields:
id UUID PK

report_name

frequency

email_recipients

is_active

last_run

next_run

created_at

Frequencies:
DAILY

WEEKLY

MONTHLY

report_history
Purpose:
Track generated reports.
Fields:
id UUID PK

report_name

generated_by

file_url

generated_at

25. Database Relationships
users
 │
 └── audit_logs

employees
 │
 ├── employee_faces
 │
 ├── attendance_sessions
 │
 └── recognition_logs

kiosks
 │
 ├── attendance_sessions
 │
 ├── recognition_logs
 │
 ├── kiosk_heartbeats
 │
 ├── kiosk_alerts
 │
 └── unrecognized_entries

26. Attendance Session Design
Session Lifecycle
Check-In
↓
ACTIVE
↓
Checkout
↓
COMPLETED

Example:
Check-In

09:00 AM

Checkout

05:30 PM

Type

MANUAL

Auto Checkout Example:
Check-In

09:00 AM

Last Recognition

05:45 PM

Checkout

05:45 PM

Type

AUTO

27. Recognition Design
Attendance:
1 Session Per Day
Recognition:
Many Events Per Day

Reason:
Cleaner Reporting

Better Analytics

Lower Complexity

28. Reporting Strategy
Reports are generated using:
attendance_sessions

recognition_logs

unrecognized_entries

kiosk_alerts

Supported Formats:
Excel

PDF

CSV

Delivery:
Download

Email

29. Data Retention Policy
Attendance Sessions:
Permanent

Employees:
Permanent

Recognition Logs:
24 Months
Configurable.

Kiosk Heartbeats:
90 Days

Audit Logs:
24 Months

30. Backup Strategy
Database Backup:
Daily

Retention:
30 Days

Restore Testing:
Monthly

31. Database Performance Targets
Attendance Query:
< 100 ms

Employee Lookup:
< 50 ms

Recognition Lookup:
< 200 ms

Dashboard Aggregation:
< 1000 ms

32. Database Security
Mandatory:
Private Network Access

Encrypted Backups

Role-Based Access

Parameterized Queries

No Direct Public Exposure

PostgreSQL Port:
5432
Must never be publicly accessible.


API Contract Specification (ACS)
Part 4 – FastAPI API Design & Integration Contracts

33. API Overview
Purpose
The API layer acts as the single source of truth for all business operations.
Responsibilities:
* Authentication
* Employee Management
* Face Registration
* Attendance Processing
* Recognition Logging
* Kiosk Management
* Kiosk Health Monitoring
* Reporting
* Audit Logging

Base URL
Development:
http://localhost:8000/api/v1
Production:
https://api.company-domain.com/api/v1

Authentication Method
JWT Bearer Token
Header:
Authorization: Bearer <access_token>

34. Standard API Response Format
Success Response
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}

Error Response
{
  "success": false,
  "message": "Validation failed",
  "errors": []
}

35. Authentication APIs
Login
Endpoint:
POST /auth/login
Purpose:
Authenticate Admin or Employee
Request:
{
  "username": "admin",
  "password": "password"
}
Response:
{
  "access_token": "",
  "refresh_token": "",
  "role": "ADMIN"
}

Refresh Token
Endpoint:
POST /auth/refresh
Request:
{
  "refresh_token": ""
}
Response:
{
  "access_token": ""
}

Logout
Endpoint:
POST /auth/logout
Purpose:
Invalidate refresh token.

36. Kiosk Authentication APIs
Kiosk Login
Endpoint:
POST /kiosk/auth/login
Request:
{
  "kiosk_code": "KIOSK_001",
  "username": "kiosk_admin",
  "password": "******"
}
Response:
{
  "access_token": "",
  "refresh_token": "",
  "kiosk_id": ""
}

Kiosk Logout
Endpoint:
POST /kiosk/auth/logout
Authorization:
ADMIN
SUPER_ADMIN
Required.

37. Employee APIs
Get Employees
Endpoint:
GET /employees
Filters:
Search

Department

Status

Get Employee
Endpoint:
GET /employees/{id}

Create Employee
Endpoint:
POST /employees
Request:
{
  "employee_code": "EMP001",
  "first_name": "John",
  "last_name": "Doe",
  "email": "",
  "phone": "",
  "department": "",
  "designation": ""
}

Update Employee
Endpoint:
PUT /employees/{id}

Deactivate Employee
Endpoint:
PATCH /employees/{id}/deactivate

38. Face Registration APIs
Upload Face
Endpoint:
POST /employees/{id}/face
Purpose:
Register employee facial data.

Request:
image

Process:
Upload Image
↓
Detect Face
↓
Generate Embedding
↓
Store Vector

Response:
{
  "employee_id": "",
  "face_id": "",
  "status": "registered"
}

Update Face
Endpoint:
PUT /employees/{id}/face

Get Face History
Endpoint:
GET /employees/{id}/faces

39. Recognition APIs
Recognition Event
Endpoint:
POST /recognition
Purpose:
Process recognition result from kiosk.

Request:
{
  "employee_id": "",
  "kiosk_id": "",
  "confidence_score": 0.92,
  "image_url": ""
}

Response:
{
  "recognized": true,
  "employee_name": "",
  "attendance_action": "CHECKIN"
}

Recognition Logs
Endpoint:
GET /recognition/logs
Filters:
Employee

Date Range

Kiosk

40. Attendance APIs
Today's Attendance
Endpoint:
GET /attendance/today

Employee Attendance History
Endpoint:
GET /attendance/history/{employee_id}

Response:
[
  {
    "check_in": "",
    "check_out": "",
    "hours": "08:30",
    "checkout_type": "MANUAL"
  }
]

Manual Checkout
Endpoint:
POST /attendance/checkout
Request:
{
  "employee_id": "",
  "kiosk_id": ""
}

Active Sessions
Endpoint:
GET /attendance/active-sessions

41. Unrecognized Entry APIs
Get Unrecognized Entries
Endpoint:
GET /unrecognized

Get Entry Details
Endpoint:
GET /unrecognized/{id}

Mark As Visitor
Endpoint:
PATCH /unrecognized/{id}/visitor

Ignore Entry
Endpoint:
PATCH /unrecognized/{id}/ignore

Register Employee
Endpoint:
POST /unrecognized/{id}/register
Purpose:
Convert unknown face into employee.

42. Kiosk APIs
Get Kiosks
Endpoint:
GET /kiosks

Register Kiosk
Endpoint:
POST /kiosks
Request:
{
  "kiosk_code": "KIOSK_001",
  "name": "Main Entrance",
  "location": "Building A"
}

Update Kiosk
Endpoint:
PUT /kiosks/{id}

Deactivate Kiosk
Endpoint:
PATCH /kiosks/{id}/deactivate

43. Kiosk Health APIs
Heartbeat API
Endpoint:
POST /kiosks/heartbeat
Interval:
60 Seconds
Request:
{
  "kiosk_id": "",
  "battery_level": 87,
  "cpu_usage": 30,
  "memory_usage": 45,
  "temperature": 38,
  "storage_available": 20480,
  "network_strength": 95,
  "app_version": "1.0.0"
}

Get Health Status
Endpoint:
GET /kiosks/{id}/health

Get Health History
Endpoint:
GET /kiosks/{id}/health/history

44. Alerts APIs
Get Alerts
Endpoint:
GET /alerts

Filters:
Severity

Kiosk

Status

Resolve Alert
Endpoint:
PATCH /alerts/{id}/resolve

45. Reports APIs
Attendance Report
Endpoint:
GET /reports/attendance
Formats:
Excel

PDF

CSV

Work Hours Report
Endpoint:
GET /reports/work-hours

Recognition Report
Endpoint:
GET /reports/recognition

Unrecognized Report
Endpoint:
GET /reports/unrecognized

Kiosk Health Report
Endpoint:
GET /reports/kiosk-health

46. Email Report APIs
Send Report
Endpoint:
POST /reports/send
Request:
{
  "report_type": "ATTENDANCE",
  "emails": [
    "admin@company.com",
    "hr@company.com"
  ]
}

Schedule Report
Endpoint:
POST /reports/schedule
Request:
{
  "report_type": "ATTENDANCE",
  "frequency": "DAILY",
  "emails": [
    "admin@company.com"
  ]
}

Frequencies:
DAILY

WEEKLY

MONTHLY

47. Settings APIs
Get Settings
Endpoint:
GET /settings

Update Settings
Endpoint:
PUT /settings

Examples:
Recognition Threshold

Cooldown Seconds

Auto Checkout Enabled

48. Audit APIs
Audit Logs
Endpoint:
GET /audit-logs
Filters:
User

Action

Date Range

49. Authorization Matrix
API Module	SUPER_ADMIN	ADMIN	HR	EMPLOYEE	KIOSK
Employees	✅	✅	✅	❌	❌
Face Registration	✅	✅	❌	❌	❌
Attendance Reports	✅	✅	✅	❌	❌
Recognition Logs	✅	✅	✅	❌	❌
Kiosks	✅	✅	❌	❌	❌
Settings	✅	❌	❌	❌	❌
Employee Dashboard	❌	❌	❌	✅	❌
Heartbeat API	❌	❌	❌	❌	✅
50. API Error Codes
Authentication
AUTH_001
Invalid Credentials

AUTH_002
Token Expired

AUTH_003
Unauthorized

Employee
EMP_001
Employee Not Found

EMP_002
Employee Already Exists

Attendance
ATT_001
Active Session Exists

ATT_002
No Active Session

Face Recognition
FACE_001
No Face Detected

FACE_002
Multiple Faces Detected

FACE_003
Face Quality Low

Kiosk
KIOSK_001
Kiosk Not Found

KIOSK_002
Kiosk Disabled

51. API Performance Targets
Authentication:
< 500 ms
Employee APIs:
< 500 ms
Attendance APIs:
< 500 ms
Recognition APIs:
< 1000 ms
Reports:
< 5 Seconds

52. API Versioning Strategy
Current Version:
/api/v1
Future:
/api/v2
Versioning is mandatory for backward compatibility.
53. Flutter Architecture Specification (FAS)
Applications
* Kiosk App
* Employee App
Both applications use the same architecture.
Architecture Pattern
* Clean Architecture
* Repository Pattern
* BLoC Pattern
* Dependency Injection
Folder Structure

lib/

├── core/
├── data/
├── presentation/
├── localization/
├── theme/
├── widgets/
├── routes/
├── firebase_options.dart
└── main.dart

Core Layer
Purpose:
Reusable application-level functionality.
Contains:

errors/
network/
services/
utils/
constants/
di/

Data Layer
Contains:

apiClient/
models/
repository/

apiClient
Files:

api_client.dart
api_helper.dart
network_interceptor.dart

Responsibilities:
* HTTP Requests
* JWT Injection
* Logging
* Retry Logic
* Error Handling
Models
Rule:
One response model per endpoint.
Examples:

employee_model.dart
attendance_history_model.dart
recognition_log_model.dart

Repository Layer
Responsibilities:
* API Communication
* Data Mapping
* Caching
* Business Data Preparation
Presentation Layer
Feature-based architecture.
Example:

dashboard_screen/
history_screen/
profile_screen/
login_screen/

Each feature contains:

feature_name/

├── bloc/
├── widgets/
└── screen.dart

BLoC Rules
Every screen contains:

event.dart
state.dart
bloc.dart

Flow:

UI
↓
Event
↓
Bloc
↓
Repository
↓
API

Widget Rules
Priority:

StatelessWidget First

Use StatefulWidget only when absolutely required.
Dependency Injection
Technology:

GetIt

Register:
* Repositories
* Services
* API Clients
* Blocs
Networking
Technology:

Dio

Features:
* Timeouts
* Retry
* Interceptors
* JWT Refresh
* Error Parsing
Localization
Location:

lib/localization

Languages:
* English
* Tamil
Future:
* Arabic
* Hindi
* Spanish
Theme
Location:

lib/theme

Contains:
* Colors
* Typography
* Spacing
* Theme Extensions

54. React Architecture Specification (RAS)
Technology Stack
* React
* TypeScript
* Redux Toolkit
* RTK Query
* Material UI
* React Router
Folder Structure

src/

├── api/
├── app/
├── components/
├── features/
├── hooks/
├── layouts/
├── pages/
├── routes/
├── store/
├── theme/
└── utils/

State Management
Technology:

Redux Toolkit

API Layer
Technology:

RTK Query

Benefits:
* Caching
* Refetching
* Invalidation
* Loading State
Layouts

AuthLayout
DashboardLayout

Route Protection
Roles:
* SUPER_ADMIN
* ADMIN
* HR
Role-based access control.
Shared Components

DataTable
Charts
Filters
Dialogs
Forms
Buttons


55. FastAPI Architecture Specification (FBS)
Folder Structure

app/

├── api/
├── core/
├── database/
├── models/
├── schemas/
├── repositories/
├── services/
├── recognition/
├── tasks/
├── middleware/
├── utils/
└── main.py

Layered Architecture

API
↓
Service
↓
Repository
↓
Database

API Layer
Responsibilities:
* Validation
* Authentication
* Response Formatting
Service Layer
Responsibilities:
* Business Logic
Examples:

AttendanceService
RecognitionService
KioskService

Repository Layer
Responsibilities:
* Database Operations
Background Jobs
Technology:

APScheduler

Jobs:
* Auto Checkout
* Report Generation
* Cleanup Jobs
* Alert Monitoring
Middleware
* JWT Validation
* Request Logging
* Rate Limiting
* Exception Handling

56. Face Recognition Engine Design
Recognition Workflow

Motion Detected
↓
Capture Frames
↓
Quality Validation
↓
Best Frame Selection
↓
Face Detection
↓
Embedding Generation
↓
Vector Search
↓
Recognition Result

Motion Detection
Purpose:
Reduce CPU Usage.
Camera runs continuously.
Recognition starts only when motion exists.
Frame Sampling
Instead of:

30 FPS Processing

Use:

2–5 FPS Processing

Quality Validation
Reject:
* Blurred Face
* Dark Image
* Multiple Faces
* Tiny Face
Best Frame Selection
Choose:

Highest Quality Frame

before recognition.
Face Detection
Technology:

InsightFace

Embedding Generation
Output:

512 Dimension Vector

Matching
Technology:

pgvector

Recognition Threshold
Configurable.
Default:

0.75

Cooldown Logic
Same Employee:

60 Seconds

Ignore duplicate recognitions.
Unknown Person Flow

Unknown Face
↓
Store Images
↓
Create Unrecognized Entry
↓
Admin Review


57. Deployment Architecture
Production Stack

Ubuntu

Docker

Docker Compose

Nginx

FastAPI

PostgreSQL

Redis

Domain Structure

api.company.com

admin.company.com

SSL
Mandatory.
Technology:

Let's Encrypt

Environment Variables

DATABASE_URL

REDIS_URL

JWT_SECRET

AES_SECRET

SMTP_CONFIG

Storage

Employee Images

Unknown Images

Generated Reports

Stored outside containers.
Recommended:

MinIO

or

Mounted Storage Volume


58. Testing Strategy
Backend Testing
Technology:

Pytest

Coverage:
* Services
* Repositories
* APIs
Flutter Testing
* Unit Tests
* Bloc Tests
* Widget Tests
React Testing
* Component Tests
* Integration Tests
Face Recognition Testing
Scenarios:
* Single Face
* Multiple Faces
* Mask
* Low Light
* Blur
* Unknown Face
UAT Testing
Validate:
* Check-In
* Checkout
* Auto Checkout
* Reports
* Alerts

59. CI/CD Strategy
Git Branches

main

develop

feature/*

Pull Requests
Mandatory:

Code Review

before merge.
Pipeline

Push
↓
Build
↓
Tests
↓
Deploy

Deployment Flow

develop
↓
Staging

main
↓
Production


60. Implementation Blueprint
Phase 1 — Foundation
Estimated Duration:

10 Hours

Tasks:
* Project Setup
* Repository Setup
* Environment Setup
* Docker Setup

Phase 2 — Database
Estimated Duration:

15 Hours

Tasks:
* PostgreSQL Setup
* Alembic Setup
* Database Models
* Indexes
* Migrations

Phase 3 — Backend Core
Estimated Duration:

30 Hours

Tasks:
* Authentication
* Employees Module
* Attendance Module
* Reports Module
* Kiosk Module

Phase 4 — Face Recognition Engine
Estimated Duration:

25 Hours

Tasks:
* InsightFace Integration
* Vector Matching
* Unknown Face Handling
* Recognition APIs

Phase 5 — Kiosk Application
Estimated Duration:

25 Hours

Tasks:
* Login
* Recognition Screen
* Checkout Mode
* Health Monitoring
* Heartbeat Service

Phase 6 — Admin Portal
Estimated Duration:

25 Hours

Tasks:
* Dashboard
* Employees
* Logs
* Unrecognized Entries
* Kiosks
* Reports
* Settings

Phase 7 — Employee Application
Estimated Duration:

15 Hours

Tasks:
* Login
* Dashboard
* Attendance History
* Profile
* Notifications
* Settings

Phase 8 — Testing & Stabilization
Estimated Duration:

15 Hours

Tasks:
* Bug Fixing
* Security Review
* Performance Optimization
* UAT Testing
* Production Validation
