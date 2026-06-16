export interface Employee {
  id: string;
  employee_code: string;
  first_name: string;
  last_name: string;
  email: string;
  phone?: string | null;
  department?: string | null;
  designation?: string | null;
  is_active: boolean;
  created_at?: string;
}

export interface EmployeeCreateRequest {
  employee_code: string;
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  department?: string;
  designation?: string;
}

export interface EmployeeUpdateRequest {
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  department?: string;
  designation?: string;
  is_active: boolean;
}
