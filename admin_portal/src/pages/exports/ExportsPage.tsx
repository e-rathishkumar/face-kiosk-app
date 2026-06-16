import {
  Box,
  Button,
  Paper,
  Stack,
  Typography,
  Grid,
  Avatar,
} from "@mui/material";

import DescriptionIcon from "@mui/icons-material/Description";
import TableChartIcon from "@mui/icons-material/TableChart";
import CameraAltIcon from "@mui/icons-material/CameraAlt";
import PersonOffIcon from "@mui/icons-material/PersonOff";
import DownloadIcon from "@mui/icons-material/Download";

import { exportService } from "../../services/exportService";

interface ExportCardProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  color: string;
  onCsv: () => void;
  onXlsx: () => void;
}

function ExportCard({
  title,
  description,
  icon,
  color,
  onCsv,
  onXlsx,
}: ExportCardProps) {
  return (
    <Paper
      sx={{
        p: 3,
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
        background: `linear-gradient(135deg, ${color}06, ${color}03)`,
        transition: "all 0.2s ease",
        "&:hover": {
          boxShadow: "0 8px 24px rgba(0,0,0,0.08)",
          transform: "translateY(-2px)",
        },
      }}
    >
      <Stack spacing={2.5}>
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar
            sx={{
              width: 48,
              height: 48,
              background: `${color}18`,
              color: color,
            }}
          >
            {icon}
          </Avatar>
          <Box>
            <Typography variant="h6" fontWeight={600}>
              {title}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {description}
            </Typography>
          </Box>
        </Stack>

        <Stack direction="row" spacing={1.5}>
          <Button
            variant="contained"
            startIcon={<DownloadIcon />}
            onClick={onCsv}
            sx={{
              borderRadius: 2,
              textTransform: "none",
              background: color,
              "&:hover": {
                background: color,
                filter: "brightness(0.9)",
              },
            }}
          >
            Export CSV
          </Button>

          <Button
            variant="outlined"
            startIcon={<TableChartIcon />}
            onClick={onXlsx}
            sx={{
              borderRadius: 2,
              textTransform: "none",
              borderColor: color,
              color: color,
              "&:hover": {
                borderColor: color,
                background: `${color}08`,
              },
            }}
          >
            Export XLSX
          </Button>
        </Stack>
      </Stack>
    </Paper>
  );
}

export default function ExportsPage() {
  return (
    <Stack spacing={3}>
      <Paper
        sx={{
          p: 3,
          borderRadius: 3,
          border: "1px solid",
          borderColor: "divider",
        }}
      >
        <Stack direction="row" alignItems="center" spacing={2}>
          <Avatar
            sx={{
              width: 42,
              height: 42,
              background:
                "linear-gradient(135deg, #6366f1, #8b5cf6)",
            }}
          >
            <DescriptionIcon />
          </Avatar>
          <Box>
            <Typography variant="h5" fontWeight={700}>
              Export Center
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Download reports in CSV or Excel format
            </Typography>
          </Box>
        </Stack>
      </Paper>

      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <ExportCard
            title="Attendance"
            description="Employee check-in/check-out records"
            icon={<DescriptionIcon />}
            color="#6366f1"
            onCsv={() => exportService.attendanceCsv()}
            onXlsx={() => exportService.attendanceXlsx()}
          />
        </Grid>

        <Grid item xs={12} md={4}>
          <ExportCard
            title="Recognition"
            description="Face recognition event logs"
            icon={<CameraAltIcon />}
            color="#10b981"
            onCsv={() => exportService.recognitionCsv()}
            onXlsx={() => exportService.recognitionXlsx()}
          />
        </Grid>

        <Grid item xs={12} md={4}>
          <ExportCard
            title="Unrecognized"
            description="Unknown face entries and reviews"
            icon={<PersonOffIcon />}
            color="#f59e0b"
            onCsv={() => exportService.unrecognizedCsv()}
            onXlsx={() => exportService.unrecognizedXlsx()}
          />
        </Grid>
      </Grid>
    </Stack>
  );
}
