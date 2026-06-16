import {
  AppBar,
  Toolbar,
  Typography,
} from "@mui/material";

export default function Topbar() {
  return (
    <AppBar position="fixed">
      <Toolbar>
        <Typography variant="h6">
          Face Recognition Admin Portal
        </Typography>
      </Toolbar>
    </AppBar>
  );
}
