import {
  Drawer,
  Box,
  Typography,
  Divider
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
  onClose
}: Props) {
  return (
    <Drawer
      anchor="right"
      open={open}
      onClose={onClose}
    >
      <Box sx={{ width: 380, p: 3 }}>
        <Typography variant="h6">
          Employee Details
        </Typography>

        <Divider sx={{ my: 2 }} />

        <Typography>
          {employee?.first_name} {employee?.last_name}
        </Typography>
      </Box>
    </Drawer>
  );
}
