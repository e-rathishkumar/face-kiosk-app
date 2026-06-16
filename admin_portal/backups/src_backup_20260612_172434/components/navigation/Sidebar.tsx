import {
  Box,
  Typography,
  List,
  ListItemButton,
  ListItemText
} from "@mui/material";

import {
  useNavigate,
  useLocation
} from "react-router-dom";

const menus = [
  {
    label: "Dashboard",
    path: "/"
  },
  {
    label: "Employees",
    path: "/employees"
  },
  {
    label: "Attendance",
    path: "/attendance"
  },
  {
    label: "Kiosks",
    path: "/kiosks"
  },
  {
    label: "Health",
    path: "/health"
  },
  {
    label: "Recognition",
    path: "/recognition"
  },
  {
    label: "Unrecognized",
    path: "/unrecognized"
  },
  {
    label: "Alerts",
    path: "/alerts"
  },
  {
    label: "Audit Logs",
    path: "/audit-logs"
  },
  {
    label: "Reports",
    path: "/reports"
  },
  {
    label: "Exports",
    path: "/exports"
  }
];

export default function Sidebar() {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <Box
      sx={{
        width: 260,
        height: "100%",
        p: 3,
        borderRight:
          "1px solid rgba(255,255,255,.08)"
      }}
    >
      <Typography
        variant="h5"
        fontWeight={700}
        mb={4}
      >
        Face Kiosk
      </Typography>

      <List>
        {menus.map(menu => (
          <ListItemButton
            key={menu.path}
            selected={
              location.pathname ===
              menu.path
            }
            onClick={() =>
              navigate(menu.path)
            }
            sx={{
              mb: 1,
              borderRadius: 2
            }}
          >
            <ListItemText
              primary={menu.label}
            />
          </ListItemButton>
        ))}
      </List>
    </Box>
  );
}
