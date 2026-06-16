import {
  Box,
  Typography
} from "@mui/material";

export default function EmptyState({
  title
}:{
  title:string
}) {
  return (
    <Box py={8} textAlign="center">
      <Typography
        variant="h6"
      >
        {title}
      </Typography>
    </Box>
  );
}
