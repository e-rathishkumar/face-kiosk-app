import {
  Paper,
  Typography,
  Stack,
  Button,
  Chip,
  Grid,
  Box,
  Avatar,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import dayjs from "dayjs";

import NotificationsActiveIcon from "@mui/icons-material/NotificationsActive";
import ErrorOutlineIcon from "@mui/icons-material/ErrorOutline";
import WarningAmberIcon from "@mui/icons-material/WarningAmber";
import CheckCircleOutlineIcon from "@mui/icons-material/CheckCircleOutline";

import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  Legend,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
} from "recharts";

import { alertService } from "../../services/alertService";

const SEVERITY_COLORS: Record<string, string> = {
  CRITICAL: "#ef4444",
  HIGH: "#f59e0b",
  MEDIUM: "#6366f1",
  LOW: "#94a3b8",
};

function AlertKpi({
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
        background: `linear-gradient(135deg, ${color}08, ${color}04)`,
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

export default function AlertsPage() {
  const [rows, setRows] = useState<any[]>([]);

  const loadData = async () => {
    const data = await alertService.getAll();
    setRows(data);
  };

  useEffect(() => {
    loadData();
    const interval = setInterval(loadData, 30000);
    return () => clearInterval(interval);
  }, []);

  const resolveAlert = async (id: string) => {
    await alertService.resolve(id);
    loadData();
  };

  const open = rows.filter((a) => !a.is_resolved).length;
  const critical = rows.filter(
    (a) => a.severity === "CRITICAL" && !a.is_resolved
  ).length;
  const high = rows.filter(
    (a) => a.severity === "HIGH" && !a.is_resolved
  ).length;
  const resolved = rows.filter((a) => a.is_resolved).length;

  // Severity distribution pie
  const severityData = Object.entries(
    rows
      .filter((a) => !a.is_resolved)
      .reduce((acc: Record<string, number>, a) => {
        acc[a.severity] = (acc[a.severity] || 0) + 1;
        return acc;
      }, {})
  ).map(([name, value]) => ({ name, value }));

  // Alert trend (last 7 days)
  const trendData = Array.from({ length: 7 }, (_, i) => {
    const date = dayjs().subtract(6 - i, "day");
    return {
      date: date.format("DD MMM"),
      fullDate: date.format("YYYY-MM-DD"),
      count: 0,
    };
  });

  rows.forEach((alert: any) => {
    const d = dayjs(typeof alert.created_at === 'string' && !alert.created_at.endsWith('Z') ? alert.created_at + 'Z' : alert.created_at).format("YYYY-MM-DD");
    const day = trendData.find((dd) => dd.fullDate === d);
    if (day) day.count += 1;
  });

  const columns = [
    {
      field: "alert_type",
      headerName: "Type",
      flex: 1.2,
      renderCell: (params: any) => (
        <Typography variant="body2" fontWeight={500}>
          {params.value}
        </Typography>
      ),
    },
    {
      field: "severity",
      headerName: "Severity",
      flex: 1,
      renderCell: (params: any) => (
        <Chip
          label={params.value}
          size="small"
          sx={{
            fontWeight: 600,
            backgroundColor: `${
              SEVERITY_COLORS[params.value] || "#94a3b8"
            }18`,
            color:
              SEVERITY_COLORS[params.value] || "#94a3b8",
            border: `1px solid ${
              SEVERITY_COLORS[params.value] || "#94a3b8"
            }40`,
          }}
        />
      ),
    },
    {
      field: "message",
      headerName: "Message",
      flex: 2.5,
    },
    {
      field: "created_at",
      headerName: "Time",
      flex: 1.5,
      valueGetter: (value: string) =>
        value
          ? dayjs(typeof value === 'string' && !value.endsWith('Z') ? value + 'Z' : value).format("DD MMM hh:mm A")
          : "-",
    },
    {
      field: "is_resolved",
      headerName: "Status",
      flex: 1,
      renderCell: (params: any) => (
        <Chip
          label={params.value ? "Resolved" : "Open"}
          color={params.value ? "success" : "error"}
          size="small"
          variant="outlined"
        />
      ),
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 1,
      sortable: false,
      renderCell: (params: any) =>
        !params.row.is_resolved ? (
          <Button
            size="small"
            variant="contained"
            color="primary"
            sx={{ borderRadius: 2, textTransform: "none" }}
            onClick={() =>
              resolveAlert(params.row.id)
            }
          >
            Resolve
          </Button>
        ) : null,
    },
  ];

  return (
    <Stack spacing={3}>
      {/* KPIs */}
      <Grid container spacing={2}>
        <Grid item xs={6} md={3}>
          <AlertKpi
            title="Open Alerts"
            value={open}
            icon={<NotificationsActiveIcon />}
            color="#6366f1"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <AlertKpi
            title="Critical"
            value={critical}
            icon={<ErrorOutlineIcon />}
            color="#ef4444"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <AlertKpi
            title="High Severity"
            value={high}
            icon={<WarningAmberIcon />}
            color="#f59e0b"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <AlertKpi
            title="Resolved"
            value={resolved}
            icon={<CheckCircleOutlineIcon />}
            color="#10b981"
          />
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
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
              Alert Trend (7 Days)
            </Typography>
            <ResponsiveContainer width="100%" height={220}>
              <AreaChart data={trendData}>
                <defs>
                  <linearGradient
                    id="alertGrad"
                    x1="0"
                    y1="0"
                    x2="0"
                    y2="1"
                  >
                    <stop
                      offset="5%"
                      stopColor="#ef4444"
                      stopOpacity={0.3}
                    />
                    <stop
                      offset="95%"
                      stopColor="#ef4444"
                      stopOpacity={0}
                    />
                  </linearGradient>
                </defs>
                <CartesianGrid
                  strokeDasharray="3 3"
                  stroke="rgba(0,0,0,0.06)"
                />
                <XAxis
                  dataKey="date"
                  tick={{ fontSize: 11 }}
                  stroke="#94a3b8"
                />
                <YAxis
                  tick={{ fontSize: 12 }}
                  stroke="#94a3b8"
                  allowDecimals={false}
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: 12,
                    border: "none",
                    boxShadow:
                      "0 4px 20px rgba(0,0,0,0.12)",
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="count"
                  name="Alerts"
                  stroke="#ef4444"
                  strokeWidth={2}
                  fill="url(#alertGrad)"
                />
              </AreaChart>
            </ResponsiveContainer>
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
              Severity Distribution
            </Typography>
            {severityData.length > 0 ? (
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie
                    data={severityData}
                    dataKey="value"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    innerRadius={45}
                    outerRadius={80}
                    paddingAngle={4}
                    strokeWidth={0}
                  >
                    {severityData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={
                          SEVERITY_COLORS[entry.name] ||
                          "#94a3b8"
                        }
                      />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend
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
                height={220}
              >
                <Chip
                  label="No Open Alerts"
                  color="success"
                />
              </Box>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Table */}
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
            Alerts Management
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
          pageSizeOptions={[10, 25, 50]}
          initialState={{
            pagination: {
              paginationModel: { pageSize: 10 },
            },
            sorting: {
              sortModel: [
                { field: "created_at", sort: "desc" },
              ],
            },
          }}
        />
      </Paper>
    </Stack>
  );
}
