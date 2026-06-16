import {
  Box,
  Button,
  Paper,
  TextField,
  Typography,
  Stack
} from "@mui/material";

import { useNavigate } from "react-router-dom";

import { useAuthStore } from "../../store/authStore";

export default function LoginPage() {

  const navigate = useNavigate();

  const login =
    useAuthStore(
      state => state.login
    );

  const handleLogin = () => {
    login("dummy-token");
    navigate("/");
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "grid",
        gridTemplateColumns: {
          xs: "1fr",
          md: "1.2fr 1fr"
        }
      }}
    >
      <Box
        sx={{
          display: {
            xs: "none",
            md: "flex"
          },
          flexDirection: "column",
          justifyContent: "center",
          p: 8,
          background:
            "linear-gradient(135deg,#0f172a,#1e293b)"
        }}
      >
        <Typography
          variant="h3"
          fontWeight={700}
        >
          Face Recognition
        </Typography>

        <Typography
          variant="h5"
          sx={{ mt: 2 }}
        >
          Enterprise Attendance Platform
        </Typography>

        <Typography
          sx={{
            mt: 3,
            color: "gray"
          }}
        >
          Monitor kiosks, attendance,
          recognition events, alerts,
          reports and employee activity.
        </Typography>
      </Box>

      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        p={3}
      >
        <Paper
          sx={{
            width: "100%",
            maxWidth: 450,
            p: 4
          }}
        >
          <Typography
            variant="h4"
            fontWeight={700}
            mb={1}
          >
            Sign In
          </Typography>

          <Typography
            color="text.secondary"
            mb={4}
          >
            Admin Portal
          </Typography>

          <Stack spacing={3}>
            <TextField
              fullWidth
              label="Email"
            />

            <TextField
              fullWidth
              type="password"
              label="Password"
            />

            <Button
              size="large"
              variant="contained"
              onClick={handleLogin}
            >
              Login
            </Button>
          </Stack>
        </Paper>
      </Box>
    </Box>
  );
}
