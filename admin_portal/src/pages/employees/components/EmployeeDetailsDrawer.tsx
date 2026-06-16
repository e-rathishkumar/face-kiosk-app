import {
  Drawer,
  Box,
  Typography,
  Divider,
  Stack,
} from "@mui/material";

import type { Employee } from "../../../types/employee";

interface Props {
  open: boolean;
  employee: Employee | null;
  onClose: () => void;
}

export default function EmployeeDetailsDrawer({
  open,
  employee,
  onClose,
}: Props) {
  return (
    <Drawer
      anchor="right"
      open={open}
      onClose={onClose}
    >
      <Box
        sx={{
          width: 420,
          p: 3,
        }}
      >
        <Typography variant="h6">
          Employee Details
        </Typography>

        <Divider sx={{ my: 2 }} />

        <Stack spacing={2}>
          <Typography>
            <strong>Employee Code:</strong>{" "}
            {employee?.employee_code ?? "-"}
          </Typography>

          <Typography>
            <strong>First Name:</strong>{" "}
            {employee?.first_name ?? "-"}
          </Typography>

          <Typography>
            <strong>Last Name:</strong>{" "}
            {employee?.last_name ?? "-"}
          </Typography>

          <Typography>
            <strong>Email:</strong>{" "}
            {employee?.email ?? "-"}
          </Typography>

          <Typography>
            <strong>Phone:</strong>{" "}
            {employee?.phone ?? "-"}
          </Typography>

          <Typography>
            <strong>Department:</strong>{" "}
            {employee?.department ?? "-"}
          </Typography>

          <Typography>
            <strong>Designation:</strong>{" "}
            {employee?.designation ?? "-"}
          </Typography>

          <Typography>
            <strong>Status:</strong>{" "}
            {employee?.is_active
              ? "Active"
              : "Inactive"}
          </Typography>
        </Stack>
      </Box>
    </Drawer>
  );
}
