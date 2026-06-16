import { createTheme } from "@mui/material/styles";

export const theme = createTheme({
  palette: {
    mode: "dark",

    primary: {
      main: "#3b82f6",
    },

    secondary: {
      main: "#8b5cf6",
    },

    background: {
      default: "#0f172a",
      paper: "#111827",
    },
  },

  shape: {
    borderRadius: 14,
  },

  typography: {
    fontFamily:
      "Inter, system-ui, sans-serif",

    h4: {
      fontWeight: 700,
    },

    h5: {
      fontWeight: 700,
    },

    h6: {
      fontWeight: 600,
    },
  },
});
