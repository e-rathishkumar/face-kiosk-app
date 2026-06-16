import {
  Paper,
  Typography,
  Box,
  Grid,
  Chip,
  Stack,
  LinearProgress,
} from "@mui/material";
import BatteryChargingFullIcon from "@mui/icons-material/BatteryChargingFull";
import MemoryIcon from "@mui/icons-material/Memory";
import StorageIcon from "@mui/icons-material/Storage";
import ThermostatIcon from "@mui/icons-material/Thermostat";

interface KioskHealthGaugesProps {
  health: any[];
}

function MetricBar({
  label,
  value,
  icon,
  color,
  suffix = "%",
}: {
  label: string;
  value: number | string;
  icon: React.ReactNode;
  color: string;
  suffix?: string;
}) {
  const numValue =
    typeof value === "number"
      ? value
      : parseFloat(value) || 0;

  return (
    <Box>
      <Stack
        direction="row"
        alignItems="center"
        spacing={0.5}
        mb={0.5}
      >
        {icon}
        <Typography variant="caption" color="text.secondary">
          {label}
        </Typography>
        <Typography
          variant="caption"
          fontWeight={700}
          ml="auto !important"
        >
          {typeof value === "number"
            ? `${value}${suffix}`
            : value}
        </Typography>
      </Stack>
      <LinearProgress
        variant="determinate"
        value={Math.min(numValue, 100)}
        sx={{
          height: 6,
          borderRadius: 3,
          backgroundColor: "rgba(0,0,0,0.06)",
          "& .MuiLinearProgress-bar": {
            borderRadius: 3,
            background: `linear-gradient(90deg, ${color}, ${color}99)`,
          },
        }}
      />
    </Box>
  );
}

function getStatusColor(status: string) {
  switch (status) {
    case "HEALTHY":
      return "success";
    case "WARNING":
      return "warning";
    case "CRITICAL":
      return "error";
    default:
      return "default";
  }
}

export default function KioskHealthGauges({
  health,
}: KioskHealthGaugesProps) {
  if (!health.length) {
    return (
      <Paper sx={{ p: 3, borderRadius: 3 }}>
        <Typography color="text.secondary">
          No kiosk health data available
        </Typography>
      </Paper>
    );
  }

  return (
    <Paper
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, rgba(139,92,246,0.04) 0%, rgba(236,72,153,0.04) 100%)",
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
      }}
    >
      <Box mb={2}>
        <Typography variant="h6" fontWeight={600}>
          Kiosk Health Overview
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Real-time device metrics
        </Typography>
      </Box>

      <Grid container spacing={2}>
        {health.map((kiosk: any) => (
          <Grid item xs={12} sm={6} md={4} key={kiosk.kiosk_id}>
            <Paper
              variant="outlined"
              sx={{
                p: 2,
                borderRadius: 2,
                transition: "all 0.2s ease",
                "&:hover": {
                  boxShadow: "0 4px 16px rgba(0,0,0,0.08)",
                  transform: "translateY(-2px)",
                },
              }}
            >
              <Stack
                direction="row"
                justifyContent="space-between"
                alignItems="center"
                mb={1.5}
              >
                <Typography variant="subtitle2" fontWeight={600}>
                  {kiosk.kiosk_name || kiosk.kiosk_id?.slice(0, 8)}
                </Typography>
                <Chip
                  label={kiosk.status}
                  size="small"
                  color={getStatusColor(kiosk.status) as any}
                  sx={{ fontWeight: 600, fontSize: 11 }}
                />
              </Stack>

              <Stack spacing={1.5}>
                <MetricBar
                  label="Battery"
                  value={kiosk.battery_level ?? 0}
                  icon={
                    <BatteryChargingFullIcon
                      sx={{ fontSize: 14, color: "#10b981" }}
                    />
                  }
                  color="#10b981"
                />
                <MetricBar
                  label="CPU"
                  value={kiosk.cpu_usage ?? 0}
                  icon={
                    <MemoryIcon
                      sx={{ fontSize: 14, color: "#6366f1" }}
                    />
                  }
                  color="#6366f1"
                />
                <MetricBar
                  label="Memory"
                  value={kiosk.memory_usage ?? 0}
                  icon={
                    <StorageIcon
                      sx={{ fontSize: 14, color: "#f59e0b" }}
                    />
                  }
                  color="#f59e0b"
                />
                <MetricBar
                  label="Temp"
                  value={kiosk.temperature ?? 0}
                  icon={
                    <ThermostatIcon
                      sx={{ fontSize: 14, color: "#ef4444" }}
                    />
                  }
                  color="#ef4444"
                  suffix="°C"
                />
              </Stack>

              {kiosk.active_alerts > 0 && (
                <Box mt={1}>
                  <Chip
                    label={`${kiosk.active_alerts} Active Alert${
                      kiosk.active_alerts > 1 ? "s" : ""
                    }`}
                    size="small"
                    color="error"
                    variant="outlined"
                    sx={{ fontSize: 11 }}
                  />
                </Box>
              )}
            </Paper>
          </Grid>
        ))}
      </Grid>
    </Paper>
  );
}
