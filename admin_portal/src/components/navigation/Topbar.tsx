import {
  AppBar,
  Toolbar,
  Typography,
  Box,
  IconButton,
  Avatar,
  Badge,
  Menu,
  MenuItem,
  ListItemIcon,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Button
} from "@mui/material";

import {
  useEffect,
  useState
} from "react";

import NotificationsIcon from "@mui/icons-material/Notifications";
import LogoutIcon from "@mui/icons-material/Logout";

import { dashboardAlertService }
  from "../../services/dashboardAlertService";

export default function Topbar() {

  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [logoutDialogOpen, setLogoutDialogOpen] = useState(false);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogoutClick = () => {
    handleMenuClose();
    setLogoutDialogOpen(true);
  };

  const handleLogoutCancel = () => {
    setLogoutDialogOpen(false);
  };

  const handleLogoutConfirm = () => {
    setLogoutDialogOpen(false);
    localStorage.removeItem("token");
    window.location.href = "/login";
  };

  const [alertCount, setAlertCount] =
    useState(0);

  const loadAlerts =
    async () => {
      try {
        const alerts =
          await dashboardAlertService
            .getActiveAlerts();

        setAlertCount(
          alerts.length
        );
      } catch (error) {
        console.error(error);
      }
    };

  useEffect(() => {
    loadAlerts();

    const interval =
      setInterval(
        loadAlerts,
        30000
      );

    return () =>
      clearInterval(
        interval
      );
  }, []);

  return (
    <>
      <AppBar
        position="sticky"
        elevation={0}
        color="transparent"
        sx={{
          backdropFilter:
            "blur(10px)",
          borderBottom:
            "1px solid rgba(255,255,255,.08)"
        }}
      >
        <Toolbar>

          <Typography
            variant="h6"
            fontWeight={700}
          >
            Face Recognition Platform
          </Typography>

          <Box flex={1} />

          <IconButton>
            <Badge
              color="error"
              badgeContent={
                alertCount
              }
            >
              <NotificationsIcon />
            </Badge>
          </IconButton>

          <IconButton onClick={handleMenuOpen} sx={{ p: 0, ml: 2 }}>
            <Avatar>A</Avatar>
          </IconButton>

          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleMenuClose}
            transformOrigin={{ horizontal: 'right', vertical: 'top' }}
            anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
            sx={{ mt: 1.5 }}
          >
            <MenuItem onClick={handleLogoutClick}>
              <ListItemIcon>
                <LogoutIcon fontSize="small" color="error" />
              </ListItemIcon>
              <Typography color="error">Logout</Typography>
            </MenuItem>
          </Menu>

        </Toolbar>
      </AppBar>

      <Dialog
        open={logoutDialogOpen}
        onClose={handleLogoutCancel}
        PaperProps={{
          sx: { borderRadius: 3, p: 1 }
        }}
      >
        <DialogTitle sx={{ fontWeight: 600 }}>Sign Out</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you would like to sign out?
          </DialogContentText>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={handleLogoutCancel} color="inherit" sx={{ fontWeight: 600 }}>
            Cancel
          </Button>
          <Button onClick={handleLogoutConfirm} variant="contained" color="error" sx={{ fontWeight: 600, borderRadius: 2 }}>
            Logout
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
}
