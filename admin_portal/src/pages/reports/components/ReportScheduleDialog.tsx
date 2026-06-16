import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  MenuItem,
  Stack,
} from "@mui/material";

import { useState } from "react";

import { reportService } from "../../../services/reportService";
import { notify } from "../../../utils/toast";

interface Props {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function ReportScheduleDialog({
  open,
  onClose,
  onSuccess,
}: Props) {
  const [reportType, setReportType] =
    useState("attendance");

  const [frequency, setFrequency] =
    useState("daily");

  const [email, setEmail] =
    useState("");

  const handleSubmit = async () => {
    await reportService.createSchedule({
      report_type: reportType,
      frequency,
      email,
    });

    notify.success(
      "Schedule created"
    );

    onSuccess();
    onClose();
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle>
        Create Schedule
      </DialogTitle>

      <DialogContent>
        <Stack spacing={3} sx={{ mt: 1 }}>
          <TextField
            select
            label="Report Type"
            value={reportType}
            onChange={(e) =>
              setReportType(
                e.target.value
              )
            }
          >
            <MenuItem value="attendance">
              Attendance
            </MenuItem>

            <MenuItem value="recognition">
              Recognition
            </MenuItem>

            <MenuItem value="unrecognized">
              Unrecognized
            </MenuItem>
          </TextField>

          <TextField
            select
            label="Frequency"
            value={frequency}
            onChange={(e) =>
              setFrequency(
                e.target.value
              )
            }
          >
            <MenuItem value="daily">
              Daily
            </MenuItem>

            <MenuItem value="weekly">
              Weekly
            </MenuItem>

            <MenuItem value="monthly">
              Monthly
            </MenuItem>
          </TextField>

          <TextField
            label="Email"
            value={email}
            onChange={(e) =>
              setEmail(
                e.target.value
              )
            }
            fullWidth
          />
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={handleSubmit}
        >
          Save
        </Button>
      </DialogActions>
    </Dialog>
  );
}
