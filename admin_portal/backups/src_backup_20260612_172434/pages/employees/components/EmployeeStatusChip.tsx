import Chip from "@mui/material/Chip";

interface Props {
  active: boolean;
}

export default function EmployeeStatusChip({
  active,
}: Props) {
  return (
    <Chip
      size="small"
      label={
        active
          ? "Active"
          : "Inactive"
      }
      color={
        active
          ? "success"
          : "default"
      }
    />
  );
}
