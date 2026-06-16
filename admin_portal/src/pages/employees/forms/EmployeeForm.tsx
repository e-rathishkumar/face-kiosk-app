import {
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Typography,
} from "@mui/material";

import { useEffect, useState } from "react";

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
  onSuccess,
}: Props) {
  const [form, setForm] = useState({
    employee_code: "",
    first_name: "",
    last_name: "",
    email: "",
    phone: "",
    department: "",
    designation: "",
  });

  const [errors, setErrors] = useState<any>({});

  useEffect(() => {
    if (employee) {
      setForm({
        employee_code: employee.employee_code ?? "",
        first_name: employee.first_name ?? "",
        last_name: employee.last_name ?? "",
        email: employee.email ?? "",
        phone: employee.phone ?? "",
        department: employee.department ?? "",
        designation: employee.designation ?? "",
      });
    } else {
      setForm({
        employee_code: "",
        first_name: "",
        last_name: "",
        email: "",
        phone: "",
        department: "",
        designation: "",
      });
    }
    setErrors({});
  }, [employee, open]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    if (errors[e.target.name]) {
      setErrors({ ...errors, [e.target.name]: null });
    }
  };

  const validate = () => {
    let tempErrors: any = {};
    if (!form.employee_code.trim()) tempErrors.employee_code = "Code is required";
    if (!form.first_name.trim()) tempErrors.first_name = "First Name is required";
    if (!form.last_name.trim()) tempErrors.last_name = "Last Name is required";
    if (!form.email.trim()) tempErrors.email = "Email is required";
    if (!form.phone.trim()) tempErrors.phone = "Phone is required";
    if (!form.department.trim()) tempErrors.department = "Department is required";
    if (!form.designation.trim()) tempErrors.designation = "Designation is required";
    
    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const saveEmployee = async () => {
    if (!validate()) {
      notify.error("Please fill in all mandatory fields");
      return;
    }

    try {
      if (employee) {
        await employeeService.update(employee.id, form);
        notify.success("Employee updated");
      } else {
        await employeeService.create(form);
        notify.success("Employee created");
      }
      onSuccess();
      onClose();
    } catch (error: any) {
      notify.error(error?.response?.data?.detail || "Failed to save employee");
    }
  };

  const RequiredLabel = ({ text }: { text: string }) => (
    <span>
      {text}{" "}
      <Typography component="span" color="error" sx={{ fontSize: "inherit" }}>
        *
      </Typography>
    </span>
  );

  const textFieldProps = {
    fullWidth: true,
    autoComplete: "off",
    sx: {
      "& input:-webkit-autofill, & input:-webkit-autofill:hover, & input:-webkit-autofill:focus, & input:-webkit-autofill:active": {
        transition: "background-color 5000s ease-in-out 0s",
        WebkitTextFillColor: "inherit !important",
      },
    }
  };

  return (
    <Dialog open={open} fullWidth maxWidth="md" onClose={onClose}>
      <DialogTitle>
        {employee ? "Edit Employee" : "Create Employee"}
      </DialogTitle>

      <DialogContent>
        <Grid container spacing={2} sx={{ mt: 0.5 }}>
          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Employee Code" />}
              name="employee_code"
              value={form.employee_code}
              onChange={handleChange}
              error={!!errors.employee_code}
              helperText={errors.employee_code}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="First Name" />}
              name="first_name"
              value={form.first_name}
              onChange={handleChange}
              error={!!errors.first_name}
              helperText={errors.first_name}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Last Name" />}
              name="last_name"
              value={form.last_name}
              onChange={handleChange}
              error={!!errors.last_name}
              helperText={errors.last_name}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Email" />}
              name="email"
              type="email"
              value={form.email}
              onChange={handleChange}
              error={!!errors.email}
              helperText={errors.email}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Phone" />}
              name="phone"
              value={form.phone}
              onChange={handleChange}
              error={!!errors.phone}
              helperText={errors.phone}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Department" />}
              name="department"
              value={form.department}
              onChange={handleChange}
              error={!!errors.department}
              helperText={errors.department}
            />
          </Grid>

          <Grid item xs={12}>
            <TextField
              {...textFieldProps}
              label={<RequiredLabel text="Designation" />}
              name="designation"
              value={form.designation}
              onChange={handleChange}
              error={!!errors.designation}
              helperText={errors.designation}
            />
          </Grid>
        </Grid>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 2, gap: 1 }}>
        <Button onClick={onClose} color="inherit" variant="outlined">
          Cancel
        </Button>
        <Button variant="contained" onClick={saveEmployee}>
          {employee ? "Update Employee" : "Save Employee"}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
