import Chip from "@mui/material/Chip";

export default function StatusChip({
  active
}:{
  active:boolean
}) {

  return (
    <Chip
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
      size="small"
    />
  );
}
