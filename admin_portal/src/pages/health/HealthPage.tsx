import {
  Paper,
  Typography,
  Stack,
  Chip,
  Grid,
  Box,
  Avatar,
  LinearProgress,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import dayjs from "dayjs";

import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import WarningAmberIcon from "@mui/icons-material/WarningAmber";
import ErrorIcon from "@mui/icons-material/Error";
import FavoriteIcon from "@mui/icons-material/Favorite";

import { healthService } from "../../services/healthService";

function HealthKpi({
  title,
  value,
  icon,
  color,
}: {
  title: string;
  value: number;
  icon: React.ReactNode;
  color: string;
}) {
  return (
    <Paper
      sx={{
        p: 2.5,
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
        transition: "all 0.2s ease",
        "&:hover": {
          boxShadow: "0 4px 16px rgba(0,0,0,0.08)",
          transform: "translateY(-2px)",
        },
      }}
    >
      <Stack direction="row" alignItems="center" spacing={2}>
        <Avatar
          sx={{
            width: 44,
            height: 44,
            background: `${color}18`,
            color: color,
          }}
        >
          {icon}
        </Avatar>
        <Box>
          <Typography variant="h4" fontWeight={700}>
            {value}
          </Typography>
          <Typography variant="caption" color="text.secondary">
            {title}
          </Typography>
        </Box>
      </Stack>
    </Paper>
  );
}

function getStatusColor(status: string): "success" | "warning" | "error" | "default" {
  switch (status) {
    case "HEALTHY":
      return "success";
    case "WARNING":
      return "warning";
    case "CRITICAL":
      return "error";
    default:
      return "default";
  }
}

function getTempColor(temp: number): string {
  if (temp >= 55) return "#ef4444";
  if (temp >= 45) return "#f59e0b";
  return "#10b981";
}

export default function HealthPage() {
  const [rows, setRows] = useState([]);

  const loadData = async () => {
    const data =
      await healthService.getKioskHealth();

    setRows(
      data.map((item: any) => ({
        ...item,
        id: item.kiosk_id,
        heartbeat: item.last_heartbeat
          ? dayjs(typeof item.last_heartbeat === 'string' && !item.last_heartbeat.endsWith('Z') ? item.last_heartbeat + 'Z' : item.last_heartbeat).format(
              "DD MMM YYYY hh:mm A"
            )
          : "-",
      }))
    );
  };

  useEffect(() => {
    loadData();
    const interval = setInterval(loadData, 30000);
    return () => clearInterval(interval);
  }, []);

  const healthy = rows.filter(
    (r: any) => r.status === "HEALTHY"
  ).length;
  const warning = rows.filter(
    (r: any) => r.status === "WARNING"
  ).length;
  const critical = rows.filter(
    (r: any) => r.status === "CRITICAL"
  ).length;

  const columns = [
    {
      field: "kiosk_name",
      headerName: "Kiosk",
      flex: 1.5,
      renderCell: (params: any) => (
        <Typography variant="body2" fontWeight={500}>
          {params.value}
        </Typography>
      ),
    },
    {
      field: "status",
      headerName: "Status",
      flex: 1,
      renderCell: (params: any) => (
        <Chip
          label={params.value}
          color={getStatusColor(params.value)}
          size="small"
          sx={{ fontWeight: 600 }}
        />
      ),
    },
    {
      field: "battery_level",
      headerName: "Battery",
      flex: 1.2,
      renderCell: (params: any) => {
        const val = params.value ?? 0;
        return (
          <Stack spacing={0.5} width="100%">
            <Typography variant="caption" fontWeight={600}>
              {val}%
            </Typography>
            <LinearProgress
              variant="determinate"
              value={val}
              sx={{
                height: 5,
                borderRadius: 3,
                backgroundColor: "rgba(0,0,0,0.06)",
                "& .MuiLinearProgress-bar": {
                  borderRadius: 3,
                  backgroundColor:
                    val > 50
                      ? "#10b981"
                      : val > 20
                      ? "#f59e0b"
                      : "#ef4444",
                },
              }}
            />
          </Stack>
        );
      },
    },
    {
      field: "cpu_usage",
      headerName: "CPU %",
      flex: 1,
      renderCell: (params: any) => {
        const val = params.value ?? 0;
        return (
          <Chip
            label={`${val}%`}
            size="small"
            variant="outlined"
            sx={{
              borderColor:
                val > 80
                  ? "#ef4444"
                  : val > 60
                  ? "#f59e0b"
                  : "#10b981",
              color:
                val > 80
                  ? "#ef4444"
                  : val > 60
                  ? "#f59e0b"
                  : "#10b981",
              fontWeight: 600,
            }}
          />
        );
      },
    },
    {
      field: "memory_usage",
      headerName: "Memory %",
      flex: 1,
      renderCell: (params: any) => {
        const val = params.value ?? 0;
        return (
          <Chip
            label={`${val}%`}
            size="small"
            variant="outlined"
            sx={{
              borderColor:
                val > 80
                  ? "#ef4444"
                  : val > 60
                  ? "#f59e0b"
                  : "#10b981",
              color:
                val > 80
                  ? "#ef4444"
                  : val > 60
                  ? "#f59e0b"
                  : "#10b981",
              fontWeight: 600,
            }}
          />
        );
      },
    },
    {
      field: "temperature",
      headerName: "Temp °C",
      flex: 1,
      renderCell: (params: any) => {
        const val = params.value ?? 0;
        return (
          <Typography
            variant="body2"
            fontWeight={600}
            sx={{ color: getTempColor(val) }}
          >
            {val}°C
          </Typography>
        );
      },
    },
    {
      field: "active_alerts",
      headerName: "Alerts",
      flex: 0.8,
      renderCell: (params: any) =>
        params.value > 0 ? (
          <Chip
            label={params.value}
            color="error"
            size="small"
          />
        ) : (
          <Typography variant="body2" color="text.secondary">
            0
          </Typography>
        ),
    },
    {
      field: "heartbeat",
      headerName: "Last Heartbeat",
      flex: 1.5,
    },
  ];

  return (
    <Stack spacing={3}>
      {/* Health KPIs */}
      <Grid container spacing={2}>
        <Grid item xs={6} md={3}>
          <HealthKpi
            title="Total Kiosks"
            value={rows.length}
            icon={<FavoriteIcon />}
            color="#6366f1"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <HealthKpi
            title="Healthy"
            value={healthy}
            icon={<CheckCircleIcon />}
            color="#10b981"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <HealthKpi
            title="Warning"
            value={warning}
            icon={<WarningAmberIcon />}
            color="#f59e0b"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <HealthKpi
            title="Critical"
            value={critical}
            icon={<ErrorIcon />}
            color="#ef4444"
          />
        </Grid>
      </Grid>

      {/* Health Table */}
      <Paper
        sx={{
          p: 3,
          borderRadius: 3,
          border: "1px solid",
          borderColor: "divider",
        }}
      >
        <Stack
          direction="row"
          justifyContent="space-between"
          alignItems="center"
          mb={2}
        >
          <Typography variant="h5" fontWeight={600}>
            Health Monitoring
          </Typography>
          <Chip
            label="Auto-refresh: 30s"
            size="small"
            variant="outlined"
            color="primary"
          />
        </Stack>

        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
          pageSizeOptions={[10, 25]}
        />
      </Paper>
    </Stack>
  );
}
