import {
  Paper,
  Typography,
  Stack,
  TextField,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useState,
} from "react";

import { auditLogService } from "../../services/auditLogService";

export default function AuditLogsPage() {
  const [rows, setRows] =
    useState([]);

  const [filter, setFilter] =
    useState("");

  const loadData =
    async () => {
      const data =
        filter.trim()
          ? await auditLogService.getByEntityType(
              filter
            )
          : await auditLogService.getAll();

      setRows(data);
    };

  useEffect(() => {
    loadData();
  }, []);

  const columns = [
    {
      field: "action",
      headerName: "Action",
      flex: 1,
    },
    {
      field: "entity_type",
      headerName: "Entity",
      flex: 1,
    },
    {
      field: "entity_id",
      headerName: "Entity ID",
      flex: 1.4,
    },
    {
      field: "new_value",
      headerName: "New Value",
      flex: 2,
    },
    {
      field: "ip_address",
      headerName: "IP Address",
      flex: 1,
    },
  ];

  return (
    <Stack spacing={3}>

      <Paper sx={{ p: 3 }}>
        <Typography
          variant="h5"
          mb={2}
        >
          Audit Logs
        </Typography>

        <TextField
          label="Entity Type"
          value={filter}
          onChange={(e) =>
            setFilter(
              e.target.value
            )
          }
          onBlur={loadData}
          sx={{ mb: 2 }}
        />

        <DataGrid
          rows={rows}
          columns={columns}
          autoHeight
        />
      </Paper>

    </Stack>
  );
}
