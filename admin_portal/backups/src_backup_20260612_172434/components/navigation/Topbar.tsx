import {
  AppBar,
  Toolbar,
  Typography,
  Box,
  IconButton,
  Avatar,
  Badge
} from "@mui/material";

import {
  useEffect,
  useState
} from "react";

import NotificationsIcon from "@mui/icons-material/Notifications";

import { dashboardAlertService }
from "../../services/dashboardAlertService";

export default function Topbar() {

  const [alertCount,setAlertCount] =
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

        <Avatar
          sx={{
            ml: 2
          }}
        >
          A
        </Avatar>

      </Toolbar>
    </AppBar>
  );
}
