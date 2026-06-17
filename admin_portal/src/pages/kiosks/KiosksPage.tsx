import {
  Paper,
  Typography,
  Button,
  Stack,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import dayjs from "dayjs";

import { kioskService } from "../../services/kioskService";

import KioskHealthChip from "./components/KioskHealthChip";
import KioskFormDialog from "./components/KioskFormDialog";

export default function KiosksPage() {
  const [rows, setRows] =
    useState([]);

  const [openDialog, setOpenDialog] =
    useState(false);

  const [selectedKiosk, setSelectedKiosk] =
    useState<any>(null);

  const loadData =
    async () => {
      const kiosks =
        await kioskService.getAll();

      const health =
        await kioskService.getHealth();

      const merged =
        kiosks.map((k: any) => {
          const healthInfo =
            health.find(
              (h: any) =>
                h.kiosk_id ===
                k.id
            );

          return {
            ...k,
            status:
              healthInfo?.status ??
              "UNKNOWN",

            battery:
              healthInfo?.battery_level ??
              "-",

            cpu:
              healthInfo?.cpu_usage ??
              "-",

            memory:
              healthInfo?.memory_usage ??
              "-",

            alerts:
              healthInfo?.active_alerts ??
              0,

            heartbeat:
              healthInfo?.last_heartbeat
                ? dayjs(typeof 
                    healthInfo.last_heartbeat
                   === 'string' && !
                    healthInfo.last_heartbeat
                  .endsWith('Z') ? 
                    healthInfo.last_heartbeat
                   + 'Z' : 
                    healthInfo.last_heartbeat
                  ).format(
                    "DD MMM YYYY"
                  )
                : "-",
          };
        });

      setRows(merged);
    };

  useEffect(() => {
    loadData();
  }, []);

  const deactivateKiosk =
    async (id: string) => {
      await kioskService.deactivate(id);
      loadData();
    };

  const columns = [
    {
      field: "kiosk_code",
      headerName: "Code",
      flex: 1,
    },
    {
      field: "name",
      headerName: "Name",
      flex: 1.2,
    },
    {
      field: "status",
      headerName: "Health",
      flex: 1,
      renderCell: (
        params: any
      ) => (
        <KioskHealthChip
          status={params.value}
        />
      ),
    },
    {
      field: "battery",
      headerName: "Battery %",
      flex: 1,
    },
    {
      field: "cpu",
      headerName: "CPU %",
      flex: 1,
    },
    {
      field: "memory",
      headerName: "Memory %",
      flex: 1,
    },
    {
      field: "alerts",
      headerName: "Alerts",
      flex: 1,
    },
    {
      field: "heartbeat",
      headerName:
        "Last Heartbeat",
      flex: 1.3,
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 2,
      sortable: false,
      renderCell: (
        params: any
      ) => (
        <Stack
          direction="row"
          spacing={1}
        >
          <Button
            size="small"
            onClick={() => {
              setSelectedKiosk(
                params.row
              );

              setOpenDialog(
                true
              );
            }}
          >
            Edit
          </Button>

          <Button
            size="small"
            color="error"
            onClick={() =>
              deactivateKiosk(
                params.row.id
              )
            }
          >
            Deactivate
          </Button>
        </Stack>
      ),
    },
  ];

  return (
    <Stack spacing={3}>
      <Paper sx={{ p: 3 }}>
        <Stack
          direction="row"
          justifyContent="space-between"
          mb={2}
        >
          <Typography
            variant="h5"
          >
            Kiosk Management
          </Typography>

          <Button
            variant="contained"
            onClick={() => {
              setSelectedKiosk(
                null
              );

              setOpenDialog(
                true
              );
            }}
          >
            Add Kiosk
          </Button>
        </Stack>

        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
        />
      </Paper>

      <KioskFormDialog
        open={openDialog}
        kiosk={selectedKiosk}
        onClose={() =>
          setOpenDialog(
            false
          )
        }
        onSuccess={loadData}
      />
    </Stack>
  );
}
