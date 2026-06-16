import {
  Box,
  Button,
  Paper,
  Stack,
  Typography,
  Chip,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import { useEffect, useState } from "react";

import dayjs from "dayjs";

import { reportService } from "../../services/reportService";

import ReportHistoryTable from "./components/ReportHistoryTable";
import ReportScheduleDialog from "./components/ReportScheduleDialog";

export default function ReportsPage() {
  const [history, setHistory] =
    useState([]);

  const [schedules, setSchedules] =
    useState<any[]>([]);

  const [openDialog, setOpenDialog] =
    useState(false);

  const loadData = async () => {
    const historyData =
      await reportService.getHistory();

    const scheduleData =
      await reportService.getSchedules();

    setHistory(historyData);
    setSchedules(scheduleData);
  };

  useEffect(() => {
    loadData();
  }, []);

  const runScheduler =
    async () => {
      await reportService.runScheduler();
      loadData();
    };

  const toggleSchedule =
    async (
      id: string,
      active: boolean
    ) => {
      if (active) {
        await reportService.deactivateSchedule(
          id
        );
      } else {
        await reportService.activateSchedule(
          id
        );
      }

      loadData();
    };

  const columns = [
    {
      field: "report_name",
      headerName: "Report",
      flex: 1.2,
    },
    {
      field: "frequency",
      headerName: "Frequency",
      flex: 1,
    },
    {
      field: "email_recipients",
      headerName: "Recipients",
      flex: 2,
    },
    {
      field: "is_active",
      headerName: "Status",
      flex: 1,
      renderCell: (
        params: any
      ) => (
        <Chip
          label={
            params.value
              ? "Active"
              : "Inactive"
          }
          color={
            params.value
              ? "success"
              : "default"
          }
          size="small"
        />
      ),
    },
    {
      field: "last_run",
      headerName: "Last Run",
      flex: 1.5,
      valueGetter: (
        value: string
      ) =>
        value
          ? dayjs(value).format(
              "DD MMM YYYY hh:mm A"
            )
          : "-",
    },
    {
      field: "next_run",
      headerName: "Next Run",
      flex: 1.5,
      valueGetter: (
        value: string
      ) =>
        value
          ? dayjs(value).format(
              "DD MMM YYYY hh:mm A"
            )
          : "-",
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 1.2,
      sortable: false,
      renderCell: (
        params: any
      ) => (
        <Button
          size="small"
          variant="contained"
          onClick={() =>
            toggleSchedule(
              params.row.id,
              params.row.is_active
            )
          }
        >
          {params.row.is_active
            ? "Deactivate"
            : "Activate"}
        </Button>
      ),
    },
  ];

  return (
    <Stack spacing={3}>
      <Paper sx={{ p: 3 }}>
        <Box
          display="flex"
          justifyContent="space-between"
          alignItems="center"
        >
          <Typography variant="h5">
            Reports Center
          </Typography>

          <Stack
            direction="row"
            spacing={2}
          >
            <Button
              variant="outlined"
              onClick={runScheduler}
            >
              Run Scheduler
            </Button>

            <Button
              variant="contained"
              onClick={() =>
                setOpenDialog(true)
              }
            >
              New Schedule
            </Button>
          </Stack>
        </Box>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h6"
          mb={2}
        >
          Report Schedules
        </Typography>

        <DataGrid
          rows={schedules}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
          pageSizeOptions={[
            10,
            25,
            50,
          ]}
        />
      </Paper>

      <ReportHistoryTable
        rows={history}
      />

      <ReportScheduleDialog
        open={openDialog}
        onClose={() =>
          setOpenDialog(false)
        }
        onSuccess={loadData}
      />
    </Stack>
  );
}
