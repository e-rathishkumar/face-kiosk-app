import {
  Card,
  CardContent,
  Typography,
  Stack,
  Chip,
} from "@mui/material";

import {
  useEffect,
  useState,
} from "react";

import { dashboardAlertService }
from "../../../services/dashboardAlertService";

export default function ActiveAlertsCard() {

  const [alerts, setAlerts] =
    useState([]);

  const loadAlerts =
    async () => {
      const data =
        await dashboardAlertService
          .getActiveAlerts();

      setAlerts(data);
    };

  useEffect(() => {
    loadAlerts();

    const timer =
      setInterval(
        loadAlerts,
        30000
      );

    return () =>
      clearInterval(timer);
  }, []);

  return (
    <Card>
      <CardContent>

        <Typography
          variant="h6"
          mb={2}
        >
          Active Alerts
        </Typography>

        <Stack spacing={1}>
          {alerts
            .slice(0, 5)
            .map((alert: any) => (
              <Chip
                key={alert.id}
                label={`${alert.severity} - ${alert.alert_type}`}
                color={
                  alert.severity ===
                  "CRITICAL"
                    ? "error"
                    : "warning"
                }
              />
            ))}
        </Stack>

      </CardContent>
    </Card>
  );
}
