import {
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  TextField,
  Grid
} from "@mui/material";

import {
  useEffect,
  useState
} from "react";

import { employeeService } from "../../../services/employeeService";
import { notify } from "../../../utils/toast";

interface Props {
  open: boolean;
  employee?: any | null;
  onClose: () => void;
  onSuccess: () => void;
}

export default function EmployeeForm({
  open,
  employee,
  onClose,
  onSuccess
}: Props) {

  const [form, setForm] = useState({
    employee_code: "",
    first_name: "",
    last_name: "",
    email: "",
    phone: "",
    department: "",
    designation: ""
  });

  useEffect(() => {
    if (employee) {
      setForm({
        employee_code:
          employee.employee_code ?? "",
        first_name:
          employee.first_name ?? "",
        last_name:
          employee.last_name ?? "",
        email:
          employee.email ?? "",
        phone:
          employee.phone ?? "",
        department:
          employee.department ?? "",
        designation:
          employee.designation ?? ""
      });
    }
  }, [employee]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement>
  ) => {
    setForm({
      ...form,
      [e.target.name]:
        e.target.value
    });
  };

  const saveEmployee =
    async () => {

      if (employee) {
        await employeeService.update(
          employee.id,
          form
        );

        notify.success(
          "Employee updated"
        );
      } else {
        await employeeService.create(
          form
        );

        notify.success(
          "Employee created"
        );
      }

      onSuccess();
      onClose();
    };

  return (
    <Dialog
      open={open}
      fullWidth
      maxWidth="md"
    >
      <DialogTitle>
        {employee
          ? "Edit Employee"
          : "Create Employee"}
      </DialogTitle>

      <DialogContent>

        <Grid
          container
          spacing={2}
          sx={{ mt: 1 }}
        >

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Employee Code"
              name="employee_code"
              value={form.employee_code}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="First Name"
              name="first_name"
              value={form.first_name}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Last Name"
              name="last_name"
              value={form.last_name}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Email"
              name="email"
              value={form.email}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Phone"
              name="phone"
              value={form.phone}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Department"
              name="department"
              value={form.department}
              onChange={handleChange}
            />
          </Grid>

          <Grid item xs={12}>
            <TextField
              fullWidth
              label="Designation"
              name="designation"
              value={form.designation}
              onChange={handleChange}
            />
          </Grid>

        </Grid>

        <Button
          variant="contained"
          sx={{ mt: 3 }}
          onClick={saveEmployee}
        >
          {employee
            ? "Update Employee"
            : "Save Employee"}
        </Button>

      </DialogContent>
    </Dialog>
  );
}
