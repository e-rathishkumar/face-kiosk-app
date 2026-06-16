import {
  Paper,
  Typography,
  Stack,
  Chip,
  Grid,
  Box,
  Tab,
  Tabs,
  Avatar,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import dayjs from "dayjs";
import duration from "dayjs/plugin/duration";

import AccessTimeIcon from "@mui/icons-material/AccessTime";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import PendingActionsIcon from "@mui/icons-material/PendingActions";
import AvTimerIcon from "@mui/icons-material/AvTimer";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";

import { attendanceService } from "../../services/attendanceService";
import { employeeService } from "../../services/employeeService";

dayjs.extend(duration);

function KpiBox({
  title,
  value,
  icon,
  color,
}: {
  title: string;
  value: string | number;
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
          <Typography variant="h5" fontWeight={700}>
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

function calculateWorkHours(
  checkIn: string,
  checkOut: string | null
): string {
  if (!checkOut) {
    const diff = dayjs().diff(dayjs(checkIn), "minute");
    const h = Math.floor(diff / 60);
    const m = diff % 60;
    return `${h}h ${m}m (ongoing)`;
  }

  const diff = dayjs(checkOut).diff(
    dayjs(checkIn),
    "minute"
  );
  const h = Math.floor(diff / 60);
  const m = diff % 60;
  return `${h}h ${m}m`;
}

export default function AttendancePage() {
  const [rows, setRows] = useState([]);
  const [tab, setTab] = useState(0);

  const loadAttendance = async () => {
    const [attendance, empData] =
      await Promise.all([
        attendanceService.getAll(),
        employeeService.getAll(),
      ]);

    const employeeMap = empData.reduce(
      (acc: any, employee: any) => {
        acc[employee.id] =
          `${employee.employee_code} - ${employee.first_name} ${employee.last_name}`;
        return acc;
      },
      {}
    );

    const formattedRows = attendance.map(
      (item: any) => ({
        ...item,
        employee_name:
          employeeMap[item.employee_id] ||
          "Unknown",
        check_in_display: dayjs(
          item.check_in_time
        ).format("DD MMM YYYY hh:mm A"),
        check_out_display: item.check_out_time
          ? dayjs(item.check_out_time).format(
              "DD MMM YYYY hh:mm A"
            )
          : "-",
        work_hours: calculateWorkHours(
          item.check_in_time,
          item.check_out_time
        ),
        checkout_type:
          item.checkout_type || "-",
      })
    );

    setRows(formattedRows);
  };

  useEffect(() => {
    loadAttendance();
  }, []);

  const activeRows = rows.filter(
    (r: any) => r.status === "ACTIVE"
  );
  const completedRows = rows.filter(
    (r: any) => r.status === "COMPLETED"
  );

  const displayRows =
    tab === 0
      ? rows
      : tab === 1
      ? activeRows
      : completedRows;

  // Calculate avg work hours for completed sessions
  const completedWithHours = rows.filter(
    (r: any) =>
      r.status === "COMPLETED" &&
      r.check_out_time
  );
  const totalMinutes = completedWithHours.reduce(
    (sum: number, r: any) => {
      return (
        sum +
        dayjs(r.check_out_time).diff(
          dayjs(r.check_in_time),
          "minute"
        )
      );
    },
    0
  );
  const avgHours =
    completedWithHours.length > 0
      ? (totalMinutes / completedWithHours.length / 60).toFixed(1)
      : "0";

  // Daily chart data
  const dailyData = Array.from({ length: 7 }, (_, i) => {
    const date = dayjs().subtract(6 - i, "day");
    return {
      date: date.format("DD MMM"),
      fullDate: date.format("YYYY-MM-DD"),
      count: 0,
    };
  });

  rows.forEach((record: any) => {
    const d = dayjs(record.check_in_time).format(
      "YYYY-MM-DD"
    );
    const day = dailyData.find(
      (dd) => dd.fullDate === d
    );
    if (day) day.count += 1;
  });

  const columns = [
    {
      field: "employee_name",
      headerName: "Employee",
      flex: 1.8,
    },
    {
      field: "check_in_display",
      headerName: "Check In",
      flex: 1.5,
    },
    {
      field: "check_out_display",
      headerName: "Check Out",
      flex: 1.5,
    },
    {
      field: "work_hours",
      headerName: "Work Hours",
      flex: 1.2,
    },
    {
      field: "checkout_type",
      headerName: "Checkout Type",
      flex: 1,
      renderCell: (params: any) =>
        params.value !== "-" ? (
          <Chip
            label={params.value}
            size="small"
            color={
              params.value === "MANUAL"
                ? "primary"
                : "default"
            }
            variant="outlined"
          />
        ) : (
          "-"
        ),
    },
    {
      field: "status",
      headerName: "Status",
      flex: 0.9,
      renderCell: (params: any) => (
        <Chip
          label={params.value}
          color={
            params.value === "ACTIVE"
              ? "success"
              : "default"
          }
          size="small"
        />
      ),
    },
  ];

  return (
    <Stack spacing={3}>
      {/* KPI Cards */}
      <Grid container spacing={2}>
        <Grid item xs={6} md={3}>
          <KpiBox
            title="Total Records"
            value={rows.length}
            icon={<AccessTimeIcon />}
            color="#6366f1"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <KpiBox
            title="Active Sessions"
            value={activeRows.length}
            icon={<PendingActionsIcon />}
            color="#10b981"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <KpiBox
            title="Completed"
            value={completedRows.length}
            icon={<CheckCircleIcon />}
            color="#8b5cf6"
          />
        </Grid>
        <Grid item xs={6} md={3}>
          <KpiBox
            title="Avg Hours"
            value={`${avgHours}h`}
            icon={<AvTimerIcon />}
            color="#f59e0b"
          />
        </Grid>
      </Grid>

      {/* Daily Chart */}
      <Paper
        sx={{
          p: 3,
          borderRadius: 3,
          border: "1px solid",
          borderColor: "divider",
        }}
      >
        <Typography variant="h6" fontWeight={600} mb={2}>
          Daily Attendance
        </Typography>
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={dailyData}>
            <CartesianGrid
              strokeDasharray="3 3"
              stroke="rgba(0,0,0,0.06)"
            />
            <XAxis
              dataKey="date"
              tick={{ fontSize: 12 }}
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
                boxShadow: "0 4px 20px rgba(0,0,0,0.12)",
              }}
            />
            <Bar
              dataKey="count"
              name="Check-ins"
              fill="#6366f1"
              radius={[6, 6, 0, 0]}
              barSize={32}
            />
          </BarChart>
        </ResponsiveContainer>
      </Paper>

      {/* Attendance Table */}
      <Paper
        sx={{
          p: 3,
          borderRadius: 3,
          border: "1px solid",
          borderColor: "divider",
        }}
      >
        <Typography variant="h5" fontWeight={600} mb={1}>
          Attendance Management
        </Typography>

        <Tabs
          value={tab}
          onChange={(_e, v) => setTab(v)}
          sx={{ mb: 2 }}
        >
          <Tab label={`All (${rows.length})`} />
          <Tab label={`Active (${activeRows.length})`} />
          <Tab
            label={`Completed (${completedRows.length})`}
          />
        </Tabs>

        <DataGrid
          rows={displayRows}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
          pageSizeOptions={[10, 25, 50]}
          initialState={{
            pagination: {
              paginationModel: { pageSize: 10 },
            },
          }}
        />
      </Paper>
    </Stack>
  );
}
