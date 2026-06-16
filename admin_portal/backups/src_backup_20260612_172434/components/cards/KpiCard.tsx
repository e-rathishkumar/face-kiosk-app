import {
  Paper,
  Typography,
  Box
} from "@mui/material";

export default function KpiCard({
  title,
  value,
  icon
}: any) {
  return (
    <Paper
      sx={{
        p: 3,
        height: 140,
        borderRadius: 4,
        background:
          "linear-gradient(180deg,#111827,#1f2937)"
      }}
    >
      <Box
        display="flex"
        justifyContent="space-between"
      >
        <Typography
          color="text.secondary"
        >
          {title}
        </Typography>

        {icon}
      </Box>

      <Typography
        variant="h3"
        fontWeight={700}
        mt={2}
      >
        {value}
      </Typography>
    </Paper>
  );
}
