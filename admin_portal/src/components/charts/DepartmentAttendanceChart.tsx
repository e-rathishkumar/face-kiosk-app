import { Paper, Typography, Box } from "@mui/material";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  Cell,
} from "recharts";

interface DepartmentAttendanceChartProps {
  attendance: any[];
  employees: any[];
}

const COLORS = [
  "#6366f1",
  "#f59e0b",
  "#10b981",
  "#ef4444",
  "#8b5cf6",
  "#06b6d4",
  "#ec4899",
  "#14b8a6",
];

export default function DepartmentAttendanceChart({
  attendance,
  employees,
}: DepartmentAttendanceChartProps) {
  const employeeDeptMap = new Map<string, string>();
  employees.forEach((emp: any) => {
    employeeDeptMap.set(
      emp.id,
      emp.department || "Unassigned"
    );
  });

  const deptCounts = new Map<string, number>();

  attendance.forEach((record: any) => {
    const dept =
      employeeDeptMap.get(record.employee_id) ||
      "Unassigned";

    deptCounts.set(
      dept,
      (deptCounts.get(dept) || 0) + 1
    );
  });

  const chartData = Array.from(deptCounts.entries())
    .map(([name, count]) => ({
      name,
      count,
    }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 8);

  return (
    <Paper
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, rgba(245,158,11,0.05) 0%, rgba(239,68,68,0.05) 100%)",
        borderRadius: 3,
        border: "1px solid",
        borderColor: "divider",
      }}
    >
      <Box mb={2}>
        <Typography variant="h6" fontWeight={600}>
          Department Breakdown
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Active attendance by department
        </Typography>
      </Box>

      <ResponsiveContainer width="100%" height={280}>
        <BarChart data={chartData} layout="vertical">
          <CartesianGrid
            strokeDasharray="3 3"
            stroke="rgba(0,0,0,0.06)"
            horizontal={false}
          />
          <XAxis
            type="number"
            tick={{ fontSize: 12 }}
            stroke="#94a3b8"
            allowDecimals={false}
          />
          <YAxis
            type="category"
            dataKey="name"
            tick={{ fontSize: 12 }}
            stroke="#94a3b8"
            width={100}
          />
          <Tooltip
            contentStyle={{
              borderRadius: 12,
              border: "none",
              boxShadow: "0 4px 20px rgba(0,0,0,0.12)",
              fontSize: 13,
            }}
          />
          <Bar dataKey="count" name="Employees" radius={[0, 6, 6, 0]} barSize={24}>
            {chartData.map((_entry, index) => (
              <Cell
                key={`cell-${index}`}
                fill={COLORS[index % COLORS.length]}
              />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </Paper>
  );
}
