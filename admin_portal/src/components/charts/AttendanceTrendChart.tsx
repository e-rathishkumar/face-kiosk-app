import { Paper, Typography, Box } from "@mui/material";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import dayjs from "dayjs";

interface AttendanceTrendChartProps {
  attendance: any[];
}

export default function AttendanceTrendChart({
  attendance,
}: AttendanceTrendChartProps) {
  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = dayjs().subtract(6 - i, "day");
    return {
      date: date.format("DD MMM"),
      fullDate: date.format("YYYY-MM-DD"),
      count: 0,
    };
  });

  attendance.forEach((record: any) => {
    const timeStr = record.check_in_time.endsWith('Z') ? record.check_in_time : `${record.check_in_time}Z`;
    const recordDate = dayjs(typeof timeStr === 'string' && !timeStr.endsWith('Z') ? timeStr + 'Z' : timeStr).format("YYYY-MM-DD");
    const day = last7Days.find((d) => d.fullDate === recordDate);
    if (day) {
      day.count += 1;
    }
  });

  return (
    <Paper
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, rgba(99,102,241,0.05) 0%, rgba(139,92,246,0.05) 100%)",
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
      }}
    >
      <Box mb={2}>
        <Typography variant="h6" fontWeight={600}>
          Attendance Trend
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Daily check-ins over the last 7 days
        </Typography>
      </Box>

      <ResponsiveContainer width="100%" height={280}>
        <LineChart data={last7Days}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
          <XAxis
            dataKey="date"
            tick={{ fontSize: 12 }}
            stroke="#94a3b8"
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
          <Line
            type="monotone"
            dataKey="count"
            name="Check-ins"
            stroke="#6366f1"
            strokeWidth={3}
            dot={{
              r: 5,
              fill: "#6366f1",
              strokeWidth: 2,
              stroke: "#fff",
            }}
            activeDot={{
              r: 7,
              fill: "#6366f1",
              strokeWidth: 2,
              stroke: "#fff",
            }}
          />
        </LineChart>
      </ResponsiveContainer>
    </Paper>
  );
}
