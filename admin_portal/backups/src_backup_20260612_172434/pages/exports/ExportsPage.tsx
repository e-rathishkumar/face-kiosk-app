import {
  Box,
  Button,
  Paper,
  Stack,
  Typography,
} from "@mui/material";

import { exportService } from "../../services/exportService";

export default function ExportsPage() {
  return (
    <Paper sx={{ p: 3 }}>
      <Typography
        variant="h5"
        mb={3}
      >
        Export Center
      </Typography>

      <Stack spacing={3}>
        <Box>
          <Typography mb={1}>
            Attendance
          </Typography>

          <Stack direction="row" spacing={2}>
            <Button
              variant="contained"
              onClick={() =>
                exportService.attendanceCsv()
              }
            >
              Export CSV
            </Button>

            <Button
              variant="outlined"
              onClick={() =>
                exportService.attendanceXlsx()
              }
            >
              Export XLSX
            </Button>
          </Stack>
        </Box>

        <Box>
          <Typography mb={1}>
            Recognition
          </Typography>

          <Stack direction="row" spacing={2}>
            <Button
              variant="contained"
              onClick={() =>
                exportService.recognitionCsv()
              }
            >
              Export CSV
            </Button>

            <Button
              variant="outlined"
              onClick={() =>
                exportService.recognitionXlsx()
              }
            >
              Export XLSX
            </Button>
          </Stack>
        </Box>

        <Box>
          <Typography mb={1}>
            Unrecognized Faces
          </Typography>

          <Stack direction="row" spacing={2}>
            <Button
              variant="contained"
              onClick={() =>
                exportService.unrecognizedCsv()
              }
            >
              Export CSV
            </Button>

            <Button
              variant="outlined"
              onClick={() =>
                exportService.unrecognizedXlsx()
              }
            >
              Export XLSX
            </Button>
          </Stack>
        </Box>
      </Stack>
    </Paper>
  );
}
