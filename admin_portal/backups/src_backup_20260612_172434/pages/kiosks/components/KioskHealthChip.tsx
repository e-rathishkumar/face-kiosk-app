import { Chip } from "@mui/material";

export default function KioskHealthChip({
  status,
}: {
  status: string;
}) {
  const color =
    status === "HEALTHY"
      ? "success"
      : status === "WARNING"
      ? "warning"
      : "error";

  return (
    <Chip
      label={status}
      color={color}
      size="small"
    />
  );
}
