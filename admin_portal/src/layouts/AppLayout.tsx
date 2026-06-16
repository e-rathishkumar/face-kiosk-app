import {
  Box,
  Drawer,
  useMediaQuery,
  useTheme
} from "@mui/material";

import Sidebar from "../components/navigation/Sidebar";
import Topbar from "../components/navigation/Topbar";

const DRAWER_WIDTH = 260;

export default function AppLayout({
  children
}: {
  children: React.ReactNode
}) {

  const theme =
    useTheme();

  const mobile =
    useMediaQuery(
      theme.breakpoints.down(
        "md"
      )
    );

  return (
    <Box
      sx={{
        display: "flex",
        minHeight: "100vh"
      }}
    >
      {!mobile && (
        <Drawer
          variant="permanent"
          PaperProps={{
            sx: {
              width:
                DRAWER_WIDTH
            }
          }}
        >
          <Sidebar />
        </Drawer>
      )}

      <Box
        sx={{
          flex: 1,
          ml: mobile
            ? 0
            : `${DRAWER_WIDTH}px`
        }}
      >
        <Topbar />

        <Box
          sx={{
            p: {
              xs: 2,
              md: 4
            }
          }}
        >
          {children}
        </Box>

      </Box>

    </Box>
  );
}
