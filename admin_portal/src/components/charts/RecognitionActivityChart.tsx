import { Paper, Typography, Box } from "@mui/material";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import dayjs from "dayjs";

interface RecognitionActivityChartProps {
  logs: any[];
}

export default function RecognitionActivityChart({
  logs,
}: RecognitionActivityChartProps) {
  const hourlyData = Array.from({ length: 24 }, (_, hour) => ({
    hour: `${hour.toString().padStart(2, "0")}:00`,
    count: 0,
  }));

  const today = dayjs().format("YYYY-MM-DD");

  logs.forEach((log: any) => {
    const logDate = dayjs(typeof log.event_time === 'string' && !log.event_time.endsWith('Z') ? log.event_time + 'Z' : log.event_time).format("YYYY-MM-DD");
    if (logDate === today) {
      const hour = dayjs(typeof log.event_time === 'string' && !log.event_time.endsWith('Z') ? log.event_time + 'Z' : log.event_time).hour();
      hourlyData[hour].count += 1;
    }
  });

  return (
    <Paper
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, rgba(16,185,129,0.05) 0%, rgba(6,182,212,0.05) 100%)",
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
      }}
    >
      <Box mb={2}>
        <Typography variant="h6" fontWeight={600}>
          Recognition Activity
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Today's hourly recognition events
        </Typography>
      </Box>

      <ResponsiveContainer width="100%" height={280}>
        <AreaChart data={hourlyData}>
          <defs>
            <linearGradient id="recognitionGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#10b981" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
          <XAxis
            dataKey="hour"
            tick={{ fontSize: 11 }}
            stroke="#94a3b8"
            interval={2}
          />
          <YAxis
            tick={{ fontSize: 12 }}
            stroke="#94a3b8"
            allowDecimals={false}
          />
          <Tooltip
            contentStyle={{
              borderRadius: 12,
              border: "none",
              boxShadow: "0 4px 20px rgba(0,0,0,0.12)",
              fontSize: 13,
            }}
          />
          <Area
            type="monotone"
            dataKey="count"
            name="Recognitions"
            stroke="#10b981"
            strokeWidth={2.5}
            fill="url(#recognitionGrad)"
          />
        </AreaChart>
      </ResponsiveContainer>
    </Paper>
  );
}
