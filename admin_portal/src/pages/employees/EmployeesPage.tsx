import {
  Paper,
  IconButton,
  Tooltip,
} from "@mui/material";

import { DataGrid } from "@mui/x-data-grid";

import {
  useEffect,
  useMemo,
  useState,
} from "react";

import VisibilityIcon from "@mui/icons-material/Visibility";
import EditIcon from "@mui/icons-material/Edit";
import FaceIcon from "@mui/icons-material/Face";
import PersonOffIcon from "@mui/icons-material/PersonOff";
import DeleteIcon from "@mui/icons-material/Delete";

import { employeeService } from "../../services/employeeService";

import EmployeeForm from "./forms/EmployeeForm";
import EmployeeToolbar from "./components/EmployeeToolbar";
import EmployeeStatusChip from "./components/EmployeeStatusChip";
import EmployeeDetailsDrawer from "./components/EmployeeDetailsDrawer";
import FaceRegistrationDialog from "./components/FaceRegistrationDialog";

import ConfirmDialog from "../../components/dialogs/ConfirmDialog";

export default function EmployeesPage() {
  const [employees, setEmployees] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [openForm, setOpenForm] = useState(false);
  const [selectedEmployee, setSelectedEmployee] = useState<any>(null);
  const [editingEmployee, setEditingEmployee] = useState<any>(null);
  const [openDrawer, setOpenDrawer] = useState(false);
  const [faceEmployeeId, setFaceEmployeeId] = useState("");
  const [openFaceDialog, setOpenFaceDialog] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [employeeToDeactivate, setEmployeeToDeactivate] = useState<string | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [employeeToDelete, setEmployeeToDelete] = useState<string | null>(null);

  const loadEmployees = async () => {
    const response = await employeeService.getAll();
    setEmployees(response);
  };

  useEffect(() => {
    loadEmployees();
  }, []);

  const deactivateEmployee = async (id: string) => {
    await employeeService.deactivate(id);
    loadEmployees();
  };

  const deleteEmployee = async (id: string) => {
    await employeeService.delete(id);
    loadEmployees();
  };

  const filteredEmployees = useMemo(() => {
    const term = search.toLowerCase();
    return employees.filter(
      (employee: any) =>
        employee.employee_code?.toLowerCase().includes(term) ||
        employee.first_name?.toLowerCase().includes(term) ||
        employee.last_name?.toLowerCase().includes(term) ||
        employee.email?.toLowerCase().includes(term)
    );
  }, [employees, search]);

  const actionBtnSx = (color: string) => ({
    color: `${color}.main`,
    border: "1px solid",
    borderColor: `${color}.main`,
    borderRadius: 1.5,
    width: 30,
    height: 30,
    "&:hover": {
      backgroundColor: `${color}.main`,
      color: "#fff",
    },
  });

  const columns = [
    { field: "employee_code", headerName: "Code", flex: 1 },
    { field: "first_name", headerName: "First Name", flex: 1 },
    { field: "last_name", headerName: "Last Name", flex: 1 },
    { field: "email", headerName: "Email", flex: 1.5 },
    { field: "department", headerName: "Department", flex: 1 },
    {
      field: "is_active",
      headerName: "Status",
      flex: 0.8,
      renderCell: (params: any) => <EmployeeStatusChip active={params.value} />,
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 1.5,
      sortable: false,
      renderCell: (params: any) => (
        <div style={{ display: "flex", alignItems: "center", gap: "6px", height: "100%" }}>
          <Tooltip title="View Details">
            <IconButton
              size="small"
              sx={actionBtnSx("primary")}
              onClick={() => {
                setSelectedEmployee(params.row);
                setOpenDrawer(true);
              }}
            >
              <VisibilityIcon sx={{ fontSize: 15 }} />
            </IconButton>
          </Tooltip>

          <Tooltip title="Edit Employee">
            <IconButton
              size="small"
              sx={actionBtnSx("warning")}
              onClick={() => {
                setEditingEmployee(params.row);
                setOpenForm(true);
              }}
            >
              <EditIcon sx={{ fontSize: 15 }} />
            </IconButton>
          </Tooltip>

          <Tooltip title="Register Face">
            <IconButton
              size="small"
              sx={actionBtnSx("info")}
              onClick={() => {
                setFaceEmployeeId(params.row.id);
                setOpenFaceDialog(true);
              }}
            >
              <FaceIcon sx={{ fontSize: 15 }} />
            </IconButton>
          </Tooltip>

          {params.row.is_active && (
            <Tooltip title="Deactivate">
              <IconButton
                size="small"
                sx={actionBtnSx("error")}
                onClick={() => {
                  setEmployeeToDeactivate(params.row.id);
                  setConfirmOpen(true);
                }}
              >
                <PersonOffIcon sx={{ fontSize: 15 }} />
              </IconButton>
            </Tooltip>
          )}

          <Tooltip title="Delete Employee">
            <IconButton
              size="small"
              sx={actionBtnSx("error")}
              onClick={() => {
                setEmployeeToDelete(params.row.id);
                setDeleteConfirmOpen(true);
              }}
            >
              <DeleteIcon sx={{ fontSize: 15 }} />
            </IconButton>
          </Tooltip>
        </div>
      ),
    },
  ];

  return (
    <>
      <Paper sx={{ p: 3 }}>
        <EmployeeToolbar
          search={search}
          onSearchChange={setSearch}
          onAddEmployee={() => {
            setEditingEmployee(null);
            setOpenForm(true);
          }}
        />

        <DataGrid
          rows={filteredEmployees}
          columns={columns}
          autoHeight
          disableRowSelectionOnClick
          rowHeight={52}
        />
      </Paper>

      <EmployeeForm
        open={openForm}
        employee={editingEmployee}
        onClose={() => {
          setOpenForm(false);
          setEditingEmployee(null);
        }}
        onSuccess={loadEmployees}
      />

      <EmployeeDetailsDrawer
        open={openDrawer}
        employee={selectedEmployee}
        onClose={() => setOpenDrawer(false)}
      />

      <FaceRegistrationDialog
        open={openFaceDialog}
        employeeId={faceEmployeeId}
        onClose={() => setOpenFaceDialog(false)}
      />

      <ConfirmDialog
        open={confirmOpen}
        title="Deactivate Employee"
        message="Are you sure you want to deactivate this employee?"
        onClose={() => setConfirmOpen(false)}
        onConfirm={async () => {
          if (employeeToDeactivate) {
            await deactivateEmployee(employeeToDeactivate);
          }
          setConfirmOpen(false);
          setEmployeeToDeactivate(null);
        }}
      />

      <ConfirmDialog
        open={deleteConfirmOpen}
        title="Delete Employee"
        message="Are you sure you want to completely delete this employee? This action cannot be undone."
        onClose={() => setDeleteConfirmOpen(false)}
        onConfirm={async () => {
          if (employeeToDelete) {
            await deleteEmployee(employeeToDelete);
          }
          setDeleteConfirmOpen(false);
          setEmployeeToDelete(null);
        }}
      />
    </>
  );
}
