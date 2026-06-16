export interface DashboardReport {
  total_employees: number;
  active_attendance: number;
  total_kiosks: number;
  recognition_logs: number;
  pending_unrecognized: number;
}

export interface ReportSchedule {
  id: string;
  report_name: string;
  frequency: string;
  email_recipients: string;
  is_active: boolean;
  last_run?: string;
  next_run?: string;
}

export interface ReportHistory {
  id: string;
  report_name: string;
  generated_by?: string;
  file_url: string;
  generated_at: string;
}

export interface CreateScheduleRequest {
  report_type: string;
  frequency: string;
  email: string;
}
