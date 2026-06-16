import {
  Grid,
  Box,
  Typography,
  Paper,
  Stack,
} from "@mui/material";

import {
  useEffect,
  useState,
} from "react";

import PeopleIcon from "@mui/icons-material/People";
import CameraAltIcon from "@mui/icons-material/CameraAlt";
import WarningIcon from "@mui/icons-material/Warning";
import BadgeIcon from "@mui/icons-material/Badge";

import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";

import KpiCard from "../../components/cards/KpiCard";

import { dashboardService } from "../../services/dashboardService";
import { healthService } from "../../services/healthService";
import { alertService } from "../../services/alertService";

import type {
  DashboardSummary,
} from "../../types/dashboard";

export default function DashboardPage() {
  const [summary, setSummary] =
    useState<DashboardSummary | null>(
      null
    );

  const [health, setHealth] =
    useState<any[]>([]);

  const [alerts, setAlerts] =
    useState<any[]>([]);

  const loadDashboard =
    async () => {
      try {
        const [
          summaryData,
          healthData,
          alertData,
        ] = await Promise.all([
          dashboardService.getSummary(),
          healthService.getKioskHealth(),
          alertService.getActive(),
        ]);

        setSummary(summaryData);
        setHealth(healthData);
        setAlerts(alertData);
      } catch (error) {
        console.error(error);
      }
    };

  useEffect(() => {
    loadDashboard();
  }, []);

  const criticalKiosks =
    health.filter(
      (k) =>
        k.status ===
        "CRITICAL"
    ).length;

  const healthyKiosks =
    health.filter(
      (k) =>
        k.status ===
        "HEALTHY"
    ).length;

  const warningKiosks =
    health.filter(
      (k) =>
        k.status ===
        "WARNING"
    ).length;

  const kioskChartData = [
    {
      name: "Healthy",
      value: healthyKiosks,
    },
    {
      name: "Warning",
      value: warningKiosks,
    },
    {
      name: "Critical",
      value: criticalKiosks,
    },
  ];

  const alertChartData = [
    {
      name: "Critical",
      value: alerts.filter(
        (a) =>
          a.severity ===
          "CRITICAL"
      ).length,
    },
    {
      name: "High",
      value: alerts.filter(
        (a) =>
          a.severity ===
          "HIGH"
      ).length,
    },
    {
      name: "Medium",
      value: alerts.filter(
        (a) =>
          a.severity ===
          "MEDIUM"
      ).length,
    },
  ];

  const summaryChartData = [
    {
      name: "Employees",
      value:
        summary?.total_employees ??
        0,
    },
    {
      name: "Attendance",
      value:
        summary?.active_attendance ??
        0,
    },
    {
      name: "Recognition",
      value:
        summary?.recognition_logs ??
        0,
    },
    {
      name: "Pending",
      value:
        summary?.pending_unrecognized ??
        0,
    },
  ];

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4">
          Dashboard
        </Typography>

        <Typography color="text.secondary">
          Face Recognition Monitoring Center
        </Typography>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Employees"
            value={
              summary?.total_employees ??
              0
            }
            icon={<PeopleIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Present Today"
            value={
              summary?.active_attendance ??
              0
            }
            icon={<BadgeIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Recognitions"
            value={
              summary?.recognition_logs ??
              0
            }
            icon={<CameraAltIcon />}
          />
        </Grid>

        <Grid item xs={12} sm={6} lg={3}>
          <KpiCard
            title="Pending Review"
            value={
              summary?.pending_unrecognized ??
              0
            }
            icon={<WarningIcon />}
          />
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography mb={2}>
              Kiosk Health
            </Typography>

            <ResponsiveContainer
              width="100%"
              height={280}
            >
              <PieChart>
                <Pie
                  data={kioskChartData}
                  dataKey="value"
                  nameKey="name"
                  outerRadius={90}
                >
                  <Cell fill="#4caf50" />
                  <Cell fill="#ff9800" />
                  <Cell fill="#f44336" />
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography mb={2}>
              Alert Severity
            </Typography>

            <ResponsiveContainer
              width="100%"
              height={280}
            >
              <BarChart
                data={alertChartData}
              >
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography mb={2}>
              Platform Metrics
            </Typography>

            <ResponsiveContainer
              width="100%"
              height={280}
            >
              <BarChart
                data={summaryChartData}
              >
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography
              variant="h6"
              mb={2}
            >
              System Status
            </Typography>

            <Stack spacing={2}>
              <Typography>
                🟢 Backend Online
              </Typography>

              <Typography>
                🟢 Database Healthy
              </Typography>

              <Typography>
                🟢 Recognition Active
              </Typography>

              <Typography>
                {criticalKiosks > 0
                  ? "🔴 Critical Kiosks Detected"
                  : "🟢 All Kiosks Healthy"}
              </Typography>

              <Typography>
                Active Alerts:{" "}
                {alerts.length}
              </Typography>
            </Stack>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
