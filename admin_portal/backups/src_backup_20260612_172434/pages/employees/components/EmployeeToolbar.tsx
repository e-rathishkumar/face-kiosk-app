import {
  Box,
  TextField,
  Button
} from "@mui/material";

interface Props {
  search: string;
  onSearchChange: (
    value: string
  ) => void;

  onAddEmployee: () => void;
}

export default function EmployeeToolbar({
  search,
  onSearchChange,
  onAddEmployee
}: Props) {

  return (
    <Box
      display="flex"
      gap={2}
      mb={3}
      flexWrap="wrap"
      justifyContent="space-between"
    >
      <TextField
        size="small"
        label="Search Employee"
        value={search}
        onChange={(e) =>
          onSearchChange(
            e.target.value
          )
        }
        sx={{
          minWidth: 280
        }}
      />

      <Button
        variant="contained"
        onClick={onAddEmployee}
      >
        Add Employee
      </Button>
    </Box>
  );
}
