import {
  BrowserRouter,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";

import {
  lazy,
  Suspense,
} from "react";

import {
  Box,
  CircularProgress,
} from "@mui/material";

import AppLayout from "../layouts/AppLayout";
import ProtectedRoute from "../routes/ProtectedRoute";

const LoginPage = lazy(
  () =>
    import(
      "../pages/auth/LoginPage"
    )
);

const DashboardPage = lazy(
  () =>
    import(
      "../pages/dashboard/DashboardPage"
    )
);

const EmployeesPage = lazy(
  () =>
    import(
      "../pages/employees/EmployeesPage"
    )
);

const AttendancePage = lazy(
  () =>
    import(
      "../pages/attendance/AttendancePage"
    )
);

const ReportsPage = lazy(
  () =>
    import(
      "../pages/reports/ReportsPage"
    )
);

const ExportsPage = lazy(
  () =>
    import(
      "../pages/exports/ExportsPage"
    )
);

const KiosksPage = lazy(
  () =>
    import(
      "../pages/kiosks/KiosksPage"
    )
);

const HealthPage = lazy(
  () =>
    import(
      "../pages/health/HealthPage"
    )
);

const RecognitionPage = lazy(
  () =>
    import(
      "../pages/recognition/RecognitionPage"
    )
);

const UnrecognizedPage = lazy(
  () =>
    import(
      "../pages/unrecognized/UnrecognizedPage"
    )
);

const AlertsPage = lazy(
  () =>
    import(
      "../pages/alerts/AlertsPage"
    )
);

const AuditLogsPage = lazy(
  () =>
    import(
      "../pages/audit-logs/AuditLogsPage"
    )
);

function PageLoader() {
  return (
    <Box
      display="flex"
      justifyContent="center"
      alignItems="center"
      height="100vh"
    >
      <CircularProgress />
    </Box>
  );
}

function ProtectedPage({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute>
      <AppLayout>
        {children}
      </AppLayout>
    </ProtectedRoute>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Suspense
        fallback={<PageLoader />}
      >
        <Routes>

          <Route
            path="/login"
            element={<LoginPage />}
          />

          <Route
            path="/"
            element={
              <ProtectedPage>
                <DashboardPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/employees"
            element={
              <ProtectedPage>
                <EmployeesPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/attendance"
            element={
              <ProtectedPage>
                <AttendancePage />
              </ProtectedPage>
            }
          />

          <Route
            path="/kiosks"
            element={
              <ProtectedPage>
                <KiosksPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/health"
            element={
              <ProtectedPage>
                <HealthPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/recognition"
            element={
              <ProtectedPage>
                <RecognitionPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/unrecognized"
            element={
              <ProtectedPage>
                <UnrecognizedPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/alerts"
            element={
              <ProtectedPage>
                <AlertsPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/audit-logs"
            element={
              <ProtectedPage>
                <AuditLogsPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/reports"
            element={
              <ProtectedPage>
                <ReportsPage />
              </ProtectedPage>
            }
          />

          <Route
            path="/exports"
            element={
              <ProtectedPage>
                <ExportsPage />
              </ProtectedPage>
            }
          />

          <Route
            path="*"
            element={
              <Navigate to="/" />
            }
          />

        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
