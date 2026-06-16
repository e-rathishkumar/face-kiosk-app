# Face Recognition Kiosk - System Information

This document contains the complete running commands, API URLs, Database URLs, and credentials for the Face Recognition Kiosk system.

## 1. Running Commands

### Backend (FastAPI)
The backend is a Python FastAPI application.
```bash
cd backend
source venv/bin/activate
# Standard run command
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
# Or, if port 8000 is occupied, use 8001:
# uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

### Admin Portal (React / Vite)
The web admin portal is a React application built with Vite.
```bash
cd admin_portal
# Install dependencies
npm install
# Run development server
npm run dev
# Build for production
npm run build
```

### Kiosk App (Flutter)
The kiosk app is a Flutter application intended for the physical device running the facial recognition.
```bash
cd kiosk_app
# Get dependencies
flutter pub get
# Run the app (ensure a device/emulator is connected)
flutter run
```

### Employee App (Flutter)
The employee app is a Flutter application for employees to view their attendance.
```bash
cd employee_app
# Get dependencies
flutter pub get
# Run the app (ensure a device/emulator is connected)
flutter run
```

---

## 2. Backend URLs Used

The web and mobile applications are configured to communicate with the local backend.

*   **Base URL (Web & Mobile)**: `http://127.0.0.1:8000` (Update `API_URL` in web and `ApiConstants.baseUrl` in Flutter if running on a physical device over Wi-Fi, e.g., `http://192.168.x.x:8000`).
*   **API Prefix**: `/api/v1` is configured in the backend environment, though the frontends communicate with the routes directly as mapped in the FastAPI routers.

### Key Endpoints Used
*   **Auth**: `/auth/login`
*   **Recognition**: `/recognition`
*   **Attendance**: `/attendance`, `/attendance/active`, `/attendance/check-in`, `/attendance/check-out`
*   **Health/Heartbeat**: `/health/kiosks`, `/heartbeat`

---

## 3. Database URLs

The backend uses PostgreSQL and Redis. These are defined in `backend/.env`.

*   **PostgreSQL**: `postgresql://postgres:postgres@localhost:5432/face_kiosk`
*   **Redis**: `redis://localhost:6379`

---

## 4. Default Credentials & Security

### Backend Security
*   **JWT Secret Key**: `face_recognition_kiosk_super_secret_key` (Configured in `backend/.env`)

### Application Logins

*   **Admin Portal User**: `admin` / `admin123`
*   **Kiosk App User**:
    *   **Username**: `admin`
    *   **Password**: `admin123`
*   **Employee App User**:
    *   **Default Password**: `staff@123` (set automatically when an employee is created from the admin portal)
    *   **Username**: The employee's **Employee Code** (in lowercase), e.g. `emp001`
    *   On first login, the employee will be prompted to **reset their password** before accessing the app.
