import {
  Paper,
  Typography,
  Stack,
  Chip,
  Select,
  MenuItem, Avatar,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import { unrecognizedService } from "../../services/unrecognizedService";

export default function UnrecognizedPage() {
  const [rows, setRows] =
    useState<any[]>([]);

  const loadData =
    async () => {
      const data =
        await unrecognizedService.getAll();

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

  const updateStatus =
    async (
      id: string,
      status: string
    ) => {
      await unrecognizedService
        .updateStatus(
          id,
          status
        );

      loadData();
    };

  const columns = [
    {
      field: "face_crop_url",
      headerName: "Face",
      flex: 0.8,

      renderCell: (
        params: any
      ) => (
        <Avatar
          src={`http://127.0.0.1:8001/${params.value}`}
          sx={{
            width: 48,
            height: 48,
          }}
        />
      ),
    },

    {
      field: "id",
      headerName: "Entry ID",
      flex: 1.5,
    },

    {
      field: "confidence_score",
      headerName: "Confidence",
      flex: 1,

      renderCell: (
        params: any
      ) => (
        <Chip
          label={`${(
            (params.value ?? 0) *
            100
          ).toFixed(2)}%`}
          color={
            params.value > 0.8
              ? "success"
              : params.value > 0.5
              ? "warning"
              : "error"
          }
        />
      ),
    },

    {
      field: "status",
      headerName: "Status",
      flex: 1.2,

      renderCell: (
        params: any
      ) => (
        <Select
          size="small"
          value={params.value}
          onChange={(e) =>
            updateStatus(
              params.row.id,
              e.target.value
            )
          }
        >
          <MenuItem value="PENDING">
            PENDING
          </MenuItem>

          <MenuItem value="VISITOR">
            VISITOR
          </MenuItem>

          <MenuItem value="REGISTERED">
            REGISTERED
          </MenuItem>

          <MenuItem value="IGNORED">
            IGNORED
          </MenuItem>
        </Select>
      ),
    },
  ];

  const pending =
    rows.filter(
      (r) =>
        r.status ===
        "PENDING"
    ).length;

  return (
    <Stack spacing={3}>
      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h5"
        >
          Unrecognized Faces
        </Typography>

        <Typography
          color="text.secondary"
          mt={1}
        >
          Pending Reviews:
          {" "}
          {pending}
        </Typography>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
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
