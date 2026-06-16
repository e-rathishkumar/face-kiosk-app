import {
  Box,
  Button,
  Paper,
  Typography,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import { useEffect, useState } from "react";

import { employeeService } from "../../services/employeeService";

import EmployeeForm from "./forms/EmployeeForm";

export default function EmployeesPage() {
  const [employees, setEmployees] =
    useState([]);

  const [openForm, setOpenForm] =
    useState(false);

  const loadEmployees = async () => {
    const response =
      await employeeService.getAll();

    setEmployees(response);
  };

  useEffect(() => {
    loadEmployees();
  }, []);

  const columns = [
    {
      field: "employee_code",
      headerName: "Code",
      flex: 1,
    },
    {
      field: "first_name",
      headerName: "First Name",
      flex: 1,
    },
    {
      field: "last_name",
      headerName: "Last Name",
      flex: 1,
    },
    {
      field: "email",
      headerName: "Email",
      flex: 1,
    },
    {
      field: "department",
      headerName: "Department",
      flex: 1,
    },
  ];

  return (
    <>
      <Paper sx={{ p: 3 }}>
        <Box
          display="flex"
          justifyContent="space-between"
          mb={2}
        >
          <Typography variant="h5">
            Employees
          </Typography>

          <Button
            variant="contained"
            onClick={() =>
              setOpenForm(true)
            }
          >
            Add Employee
          </Button>
        </Box>

        <DataGrid
          rows={employees}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
        />
      </Paper>

      <EmployeeForm
        open={openForm}
        onClose={() =>
          setOpenForm(false)
        }
        onSuccess={loadEmployees}
      />
    </>
  );
}
