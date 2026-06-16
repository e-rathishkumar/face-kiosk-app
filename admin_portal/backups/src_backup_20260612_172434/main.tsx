import React from "react";
import ReactDOM from "react-dom/client";

import { ThemeProvider } from "@mui/material/styles";
import { CssBaseline } from "@mui/material";

import { Toaster } from "react-hot-toast";

import App from "./app/App";

import { theme } from "./theme/theme";

ReactDOM.createRoot(
  document.getElementById("root")!
).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <Toaster
        position="top-right"
        toastOptions={{
          duration: 3000,
        }}
      />

      <App />
    </ThemeProvider>
  </React.StrictMode>
);
