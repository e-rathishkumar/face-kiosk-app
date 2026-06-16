import {
  Paper,
  Typography,
  Stack,
  Button,
  Chip,
  Grid,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import { alertService } from "../../services/alertService";

export default function AlertsPage() {
  const [rows, setRows] =
    useState<any[]>([]);

  const loadData =
    async () => {
      const data =
        await alertService.getAll();

      setRows(data);
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

  const resolveAlert =
    async (
      id: string
    ) => {
      await alertService.resolve(id);
      loadData();
    };

  const critical =
    rows.filter(
      (a) =>
        a.severity ===
          "CRITICAL" &&
        !a.is_resolved
    ).length;

  const high =
    rows.filter(
      (a) =>
        a.severity ===
          "HIGH" &&
        !a.is_resolved
    ).length;

  const open =
    rows.filter(
      (a) =>
        !a.is_resolved
    ).length;

  const columns = [
    {
      field: "alert_type",
      headerName: "Type",
      flex: 1.2,
    },
    {
      field: "severity",
      headerName: "Severity",
      flex: 1,
      renderCell: (
        params: any
      ) => (
        <Chip
          label={params.value}
          color={
            params.value ===
            "CRITICAL"
              ? "error"
              : params.value ===
                "HIGH"
              ? "warning"
              : "default"
          }
        />
      ),
    },
    {
      field: "message",
      headerName: "Message",
      flex: 2,
    },
    {
      field: "is_resolved",
      headerName: "Status",
      flex: 1,
      renderCell: (
        params: any
      ) => (
        <Chip
          label={
            params.value
              ? "Resolved"
              : "Open"
          }
          color={
            params.value
              ? "success"
              : "error"
          }
        />
      ),
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 1,
      renderCell: (
        params: any
      ) =>
        !params.row
          .is_resolved ? (
          <Button
            size="small"
            variant="contained"
            onClick={() =>
              resolveAlert(
                params.row.id
              )
            }
          >
            Resolve
          </Button>
        ) : null,
    },
  ];

  return (
    <Stack spacing={3}>

      <Grid container spacing={2}>
        <Grid item xs={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h4">
              {open}
            </Typography>
            <Typography>
              Open Alerts
            </Typography>
          </Paper>
        </Grid>

        <Grid item xs={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h4">
              {critical}
            </Typography>
            <Typography>
              Critical
            </Typography>
          </Paper>
        </Grid>

        <Grid item xs={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h4">
              {high}
            </Typography>
            <Typography>
              High Severity
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h5"
          mb={2}
        >
          Alerts Management
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
