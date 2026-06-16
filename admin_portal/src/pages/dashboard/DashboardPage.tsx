import {
  Grid,
  Box,
  Typography,
  Paper,
  Stack,
  Chip,
  Avatar,
} from "@mui/material";

import {
  useEffect,
  useState,
} from "react";

import PeopleIcon from "@mui/icons-material/People";
import CameraAltIcon from "@mui/icons-material/CameraAlt";
import WarningIcon from "@mui/icons-material/Warning";
import BadgeIcon from "@mui/icons-material/Badge";
import TrendingUpIcon from "@mui/icons-material/TrendingUp";

import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  Legend,
} from "recharts";

import KpiCard from "../../components/cards/KpiCard";
import AttendanceTrendChart from "../../components/charts/AttendanceTrendChart";
import RecognitionActivityChart from "../../components/charts/RecognitionActivityChart";
import DepartmentAttendanceChart from "../../components/charts/DepartmentAttendanceChart";
import KioskHealthGauges from "../../components/charts/KioskHealthGauges";

import { dashboardService } from "../../services/dashboardService";
import { healthService } from "../../services/healthService";
import { alertService } from "../../services/alertService";
import { attendanceService } from "../../services/attendanceService";
import { recognitionService } from "../../services/recognitionService";
import { employeeService } from "../../services/employeeService";

import type {
  DashboardSummary,
} from "../../types/dashboard";

const PIE_COLORS = ["#10b981", "#f59e0b", "#ef4444"];
const SEVERITY_COLORS = ["#ef4444", "#f59e0b", "#6366f1"];

export default function DashboardPage() {
  const [summary, setSummary] =
    useState<DashboardSummary | null>(null);

  const [health, setHealth] =
    useState<any[]>([]);

  const [alerts, setAlerts] =
    useState<any[]>([]);

  const [attendance, setAttendance] =
    useState<any[]>([]);

  const [recognitionLogs, setRecognitionLogs] =
    useState<any[]>([]);

  const [employees, setEmployees] =
    useState<any[]>([]);

  const loadDashboard = async () => {
    try {
      const [
        summaryData,
        healthData,
        alertData,
        attendanceData,
        logData,
        empData,
      ] = await Promise.all([
        dashboardService.getSummary(),
        healthService.getKioskHealth(),
        alertService.getActive(),
        attendanceService.getAll(),
        recognitionService.getAll(),
        employeeService.getAll(),
      ]);

      setSummary(summaryData);
      setHealth(healthData);
      setAlerts(alertData);
      setAttendance(attendanceData);
      setRecognitionLogs(logData);
      setEmployees(empData);
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    loadDashboard();

    const interval = setInterval(loadDashboard, 60000);
    return () => clearInterval(interval);
  }, []);

  const criticalKiosks =
    health.filter(
      (k) => k.status === "CRITICAL"
    ).length;

  const healthyKiosks =
    health.filter(
      (k) => k.status === "HEALTHY"
    ).length;

  const warningKiosks =
    health.filter(
      (k) => k.status === "WARNING"
    ).length;

  const onlineKiosks =
    healthyKiosks + warningKiosks;

  const kioskChartData = [
    { name: "Healthy", value: healthyKiosks },
    { name: "Warning", value: warningKiosks },
    { name: "Critical", value: criticalKiosks },
  ].filter((d) => d.value > 0);

  const alertChartData = [
    {
      name: "Critical",
      value: alerts.filter(
        (a) => a.severity === "CRITICAL"
      ).length,
    },
    {
      name: "High",
      value: alerts.filter(
        (a) => a.severity === "HIGH"
      ).length,
    },
    {
      name: "Medium",
      value: alerts.filter(
        (a) => a.severity === "MEDIUM"
      ).length,
    },
  ].filter((d) => d.value > 0);

  const activeAttendance = attendance.filter(
    (a: any) => a.status === "ACTIVE"
  );

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Stack direction="row" alignItems="center" spacing={1.5}>
          <Avatar
            sx={{
              width: 42,
              height: 42,
              background: "linear-gradient(135deg, #6366f1, #8b5cf6)",
            }}
          >
            <TrendingUpIcon />
          </Avatar>
          <Box>
            <Typography variant="h4" fontWeight={700}>
              Dashboard
            </Typography>
            <Typography color="text.secondary" variant="body2">
              Face Recognition Monitoring Center
            </Typography>
          </Box>
        </Stack>
      </Box>

      {/* KPI Cards */}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Employees"
            value={summary?.total_employees ?? 0}
            icon={<PeopleIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Present Today"
            value={activeAttendance.length}
            icon={<BadgeIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Recognitions"
            value={summary?.recognition_logs ?? 0}
            icon={<CameraAltIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Pending Review"
            value={summary?.pending_unrecognized ?? 0}
            icon={<WarningIcon />}
          />
        </Grid>

        {/* Attendance Trend */}
        <Grid item xs={12} md={6}>
          <AttendanceTrendChart attendance={attendance} />
        </Grid>

        {/* Recognition Activity */}
        <Grid item xs={12} md={6}>
          <RecognitionActivityChart logs={recognitionLogs} />
        </Grid>

        {/* Department Breakdown */}
        <Grid item xs={12} md={6}>
          <DepartmentAttendanceChart
            attendance={activeAttendance}
            employees={employees}
          />
        </Grid>

        {/* Kiosk Health Pie */}
        <Grid item xs={12} md={6}>
          <Paper
            sx={{
              p: 3,
              borderRadius: 3,
              border: "1px solid",
              borderColor: "divider",
            }}
          >
            <Box mb={2}>
              <Typography variant="h6" fontWeight={600}>
                Kiosk Status
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {onlineKiosks} of {health.length} kiosks online
              </Typography>
            </Box>

            {kioskChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={kioskChartData}
                    dataKey="value"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={90}
                    paddingAngle={4}
                    strokeWidth={0}
                  >
                    {kioskChartData.map((_entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={PIE_COLORS[index % PIE_COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend
                    verticalAlign="bottom"
                    iconType="circle"
                    iconSize={8}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <Box
                display="flex"
                alignItems="center"
                justifyContent="center"
                height={250}
              >
                <Typography color="text.secondary">
                  No kiosk data available
                </Typography>
              </Box>
            )}
          </Paper>
        </Grid>

        {/* Kiosk Health Gauges */}
        <Grid item xs={12}>
          <KioskHealthGauges health={health} />
        </Grid>

        {/* Alert Severity + System Status */}
        <Grid item xs={12} md={6}>
          <Paper
            sx={{
              p: 3,
              borderRadius: 3,
              border: "1px solid",
              borderColor: "divider",
            }}
          >
            <Box mb={2}>
              <Typography variant="h6" fontWeight={600}>
                Alert Severity
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {alerts.length} active alerts
              </Typography>
            </Box>

            {alertChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={alertChartData}
                    dataKey="value"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={90}
                    paddingAngle={4}
                    strokeWidth={0}
                  >
                    {alertChartData.map((_entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={
                          SEVERITY_COLORS[
                            index % SEVERITY_COLORS.length
                          ]
                        }
                      />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend
                    verticalAlign="bottom"
                    iconType="circle"
                    iconSize={8}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <Box
                display="flex"
                alignItems="center"
                justifyContent="center"
                height={250}
              >
                <Stack alignItems="center" spacing={1}>
                  <Chip
                    label="No Active Alerts"
                    color="success"
                    icon={<span>✅</span>}
                  />
                </Stack>
              </Box>
            )}
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper
            sx={{
              p: 3,
              borderRadius: 3,
              border: "1px solid",
              borderColor: "divider",
            }}
          >
            <Typography variant="h6" fontWeight={600} mb={2}>
              System Status
            </Typography>

            <Stack spacing={2}>
              <StatusRow
                label="Backend"
                status="online"
              />
              <StatusRow
                label="Database"
                status="online"
              />
              <StatusRow
                label="Recognition Engine"
                status="online"
              />
              <StatusRow
                label="Kiosk Network"
                status={
                  criticalKiosks > 0
                    ? "critical"
                    : warningKiosks > 0
                    ? "warning"
                    : "online"
                }
                detail={
                  criticalKiosks > 0
                    ? `${criticalKiosks} critical`
                    : warningKiosks > 0
                    ? `${warningKiosks} warnings`
                    : "All healthy"
                }
              />
              <StatusRow
                label="Online Kiosks"
                status="online"
                detail={`${onlineKiosks} / ${health.length}`}
              />
              <StatusRow
                label="Active Alerts"
                status={
                  alerts.length > 0 ? "warning" : "online"
                }
                detail={`${alerts.length} alert${
                  alerts.length !== 1 ? "s" : ""
                }`}
              />
            </Stack>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}

function StatusRow({
  label,
  status,
  detail,
}: {
  label: string;
  status: "online" | "warning" | "critical";
  detail?: string;
}) {
  const icon =
    status === "online"
      ? "🟢"
      : status === "warning"
      ? "🟡"
      : "🔴";

  return (
    <Stack
      direction="row"
      alignItems="center"
      justifyContent="space-between"
      sx={{
        p: 1.5,
        borderRadius: 2,
        backgroundColor:
          status === "online"
            ? "rgba(16,185,129,0.06)"
            : status === "warning"
            ? "rgba(245,158,11,0.06)"
            : "rgba(239,68,68,0.06)",
      }}
    >
      <Stack direction="row" alignItems="center" spacing={1}>
        <Typography fontSize={16}>{icon}</Typography>
        <Typography variant="body2" fontWeight={500}>
          {label}
        </Typography>
      </Stack>
      {detail && (
        <Typography variant="caption" color="text.secondary">
          {detail}
        </Typography>
      )}
    </Stack>
  );
}
