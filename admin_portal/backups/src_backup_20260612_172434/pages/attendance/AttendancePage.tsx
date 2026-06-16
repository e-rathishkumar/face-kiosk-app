import {
  Paper,
  Typography,
  Stack,
  Chip,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import dayjs from "dayjs";

import { attendanceService } from "../../services/attendanceService";
import { employeeService } from "../../services/employeeService";

export default function AttendancePage() {
  const [rows, setRows] =
    useState([]);

  const loadAttendance =
    async () => {
      const [
        attendance,
        employees,
      ] = await Promise.all([
        attendanceService.getAll(),
        employeeService.getAll(),
      ]);

      const employeeMap =
        employees.reduce(
          (acc: any, employee: any) => {
            acc[employee.id] =
              `${employee.employee_code} - ${employee.first_name} ${employee.last_name}`;

            return acc;
          },
          {}
        );

      const formattedRows =
        attendance.map(
          (item: any) => ({
            ...item,

            employee_name:
              employeeMap[
                item.employee_id
              ] || "Unknown",

            check_in_display:
              dayjs(item.check_in_time).format("hh:mm A"),

            check_out_display:
              item.check_out_time
                ? dayjs(item.check_out_time).format("hh:mm A")
                : "-",
          })
        );

      setRows(formattedRows);
    };

  useEffect(() => {
    loadAttendance();
  }, []);

  const columns = [
    {
      field: "employee_name",
      headerName: "Employee",
      flex: 1.8,
    },
    {
      field: "check_in_display",
      headerName: "Check In",
      flex: 1.3,
    },
    {
      field: "check_out_display",
      headerName: "Check Out",
      flex: 1.3,
    },
    {
      field: "status",
      headerName: "Status",
      flex: 0.8,

      renderCell: (params: any) => (
        <Chip
          label={params.value}
          color={
            params.value ===
            "ACTIVE"
              ? "success"
              : "default"
          }
        />
      ),
    },
  ];

  return (
    <Stack spacing={3}>
      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h5"
          mb={2}
        >
          Attendance Management
        </Typography>

        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
        />
      </Paper>
    </Stack>
  );
}
