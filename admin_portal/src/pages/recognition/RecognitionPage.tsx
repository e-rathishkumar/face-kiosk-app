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

import { recognitionService }
from "../../services/recognitionService";

import { employeeService }
from "../../services/employeeService";

export default function RecognitionPage() {

  const [rows, setRows] =
    useState<any[]>([]);

  const loadData =
    async () => {

      const [
        logs,
        employees,
      ] = await Promise.all([
        recognitionService.getAll(),
        employeeService.getAll(),
      ]);

      const employeeMap =
        new Map(
          employees.map(
            (e: any) => [
              e.id,
              `${e.employee_code} - ${e.first_name} ${e.last_name}`,
            ]
          )
        );

      const formatted =
        logs.map(
          (log: any) => ({
            ...log,

            employee_name:
              employeeMap.get(
                log.employee_id
              ) ??
              "Unknown Employee",

            kiosk_short:
              log.kiosk_id.slice(
                0,
                8
              ),

            confidence_display:
              `${(
                log.confidence_score *
                100
              ).toFixed(2)}%`,

            event_display:
              dayjs(
                log.event_time
              ).format(
                "DD MMM YYYY hh:mm A"
              ),
          })
        );

      setRows(formatted);
    };

  useEffect(() => {
    loadData();
  }, []);

  const columns = [
    {
      field: "employee_name",
      headerName: "Employee",
      flex: 2,
    },

    {
      field: "kiosk_short",
      headerName: "Kiosk",
      flex: 1,
    },

    {
      field:
        "confidence_display",
      headerName:
        "Confidence",
      flex: 1,

      renderCell:
        (params: any) => {

          const value =
            parseFloat(
              params.row.confidence_display
            );

          return (
            <Chip
              label={
                params.value
              }
              color={
                value >= 90
                  ? "success"
                  : value >= 70
                  ? "warning"
                  : "error"
              }
              size="small"
            />
          );
        },
    },

    {
      field: "event_display",
      headerName:
        "Recognition Time",
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
          Recognition Logs
        </Typography>

        <DataGrid
          rows={rows}
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

    </Stack>
  );
}
