export interface Attendance {
  id: string;
  employee_id: string;
  kiosk_id: string;
  check_in_time: string;
  check_out_time?: string | null;
  status: string;
}
