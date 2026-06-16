# Face Recognition Kiosk Deployment Guide

This guide provides step-by-step instructions to deploy the backend, admin portal, and configure the mobile apps for production usage via Render.

## Prerequisites
- A GitHub account.
- A Render account (https://render.com).
- Git installed on your local machine.

---

## Step 1: Push the Code to GitHub

1. Create a new, empty repository on your GitHub account. Do NOT add a README, `.gitignore`, or license during creation.
2. Open your terminal in the root directory of this project (`Face Recognition Kiosk`).
3. Run the following commands to push your local code to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for deployment"
   git branch -M main
   git remote add origin https://github.com/your-username/your-repo-name.git
   git push -u origin main
   ```
   *(Make sure to replace the URL with your actual GitHub repo URL)*

---

## Step 2: Deploy PostgreSQL and Redis (Free Tier)

Our backend requires a database and a caching layer. 

### Deploy PostgreSQL
1. On your Render dashboard, click **New +** > **PostgreSQL**.
2. Name it `face-kiosk-db`.
3. Choose the **Free** instance type.
4. Click **Create Database**.
5. Once created, copy the **Internal Database URL** (if deploying backend to Render) or the **External Database URL**. 

### Deploy Redis (Key Value)
Render offers Redis under the name "Key Value":
1. Click **New +** > **Key Value**.
2. Name it `face-kiosk-redis`.
3. Choose the **Free** instance type.
4. Click **Create Key Value**.
5. Copy the **Internal Redis URL** (it will look like `redis://...`).

*(Note: Render's free PostgreSQL databases expire after 90 days. For persistent usage, consider upgrading the DB or using an external managed DB like Supabase).*

---

## Step 3: Deploy the Backend to Render

We will deploy the FastAPI backend using Docker.

1. On the Render Dashboard, click **New +** > **Web Service**.
2. Select **"Build and deploy from a Git repository"** and connect your GitHub repo.
3. Configure the service as follows:
   - **Name**: `face-kiosk-backend`
   - **Root Directory**: `backend`
   - **Environment**: `Docker`
   - **Branch**: `main`
   - **Instance Type**: Select your preferred tier. (Note: The free tier may face memory constraints installing OpenCV/InsightFace. A Starter tier is recommended).
4. Click **Advanced** and add the following **Environment Variables**:
   - `DATABASE_URL` : Paste your PostgreSQL URL here.
   - `REDIS_URL` : Paste your Redis URL here.
   - `JWT_SECRET` : Generate a strong random string (e.g., `face_recognition_kiosk_super_secret_key`).
   - `APP_NAME` : `Face Recognition Kiosk`
   - `API_V1_PREFIX` : `/api/v1`
5. **Persistent Disk (Important for Images):** Under Advanced, click **Add Disk**.
   - Name: `uploads-disk`
   - Mount Path: `/app/uploads`
   - Size: `1 GB`
   *(Note: This requires a paid instance. **If you are on the FREE plan, SKIP this step entirely.** The only downside is that uploaded profile photos will be wiped when the free server goes to sleep).*
6. Click **Create Web Service**. Wait for the build to finish. Once live, copy the URL (e.g., `https://face-kiosk-backend.onrender.com`).

---

## Step 4: Deploy the Admin Portal (Static Site)

1. On the Render Dashboard, click **New +** > **Static Site**.
2. Select the same GitHub repository.
3. Configure the static site:
   - **Name**: `face-kiosk-admin`
   - **Root Directory**: `admin_portal`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
4. Add the following **Environment Variables**:
   - `VITE_API_URL` : Paste your new Backend URL (e.g., `https://face-kiosk-backend.onrender.com/api/v1`)
5. Click **Advanced** and add a **Rewrite Rule** (To fix React Router on page refresh):
   - **Source**: `/*`
   - **Destination**: `/index.html`
   - **Action**: `Rewrite`
6. Click **Create Static Site**.

---

## Step 5: Update the Mobile Apps

Now that your backend is hosted live, you need to point the Flutter apps to the new URL.

### 1. Update Employee App
- Open `employee_app/lib/core/constants/api_constants.dart` (or `.env` if used).
- Update the `baseUrl` to your new Render backend URL.
  ```dart
  static const String baseUrl = 'https://face-kiosk-backend.onrender.com';
  ```
- Build the APK: `flutter build apk`

### 2. Update Kiosk App
- Open `kiosk_app/lib/core/constants.dart` (or wherever `ApiConstants.baseUrl` is defined).
- Update the URL to point to the live server.
- Build the APK: `flutter build apk`

## Congratulations!
Your Face Recognition System is now successfully deployed and live!
