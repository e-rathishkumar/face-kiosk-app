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

import { healthService } from "../../services/healthService";

export default function HealthPage() {
  const [rows, setRows] =
    useState([]);

  const loadData =
    async () => {
      const data =
        await healthService.getKioskHealth();

      setRows(
        data.map(
          (item: any) => ({
            ...item,

            heartbeat:
              item.last_heartbeat
                ? dayjs(
                    item.last_heartbeat
                  ).format(
                    "DD MMM YYYY hh:mm A"
                  )
                : "-",
          })
        )
      );
    };

  useEffect(() => {
    loadData();

    const interval =
      setInterval(
        loadData,
        30000
      );

    return () =>
      clearInterval(
        interval
      );
  }, []);

  const columns = [
    {
      field: "kiosk_name",
      headerName: "Kiosk",
      flex: 1.5,
    },
    {
      field: "status",
      headerName: "Status",
      flex: 1,
      renderCell: (
        params: any
      ) => (
        <Chip
          label={params.value}
          color={
            params.value ===
            "HEALTHY"
              ? "success"
              : "error"
          }
        />
      ),
    },
    {
      field: "battery_level",
      headerName: "Battery",
      flex: 1,
    },
    {
      field: "cpu_usage",
      headerName: "CPU %",
      flex: 1,
    },
    {
      field: "memory_usage",
      headerName: "Memory %",
      flex: 1,
    },
    {
      field: "temperature",
      headerName: "Temp °C",
      flex: 1,
    },
    {
      field: "active_alerts",
      headerName: "Alerts",
      flex: 1,
    },
    {
      field: "heartbeat",
      headerName: "Last Heartbeat",
      flex: 1.5,
    },
  ];

  return (
    <Stack spacing={3}>
      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h5"
          mb={2}
        >
          Health Monitoring
        </Typography>

        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
        />
      </Paper>
    </Stack>
  );
}
