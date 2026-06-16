export interface DashboardAlert {
  id: string;
  kiosk_id: string;
  alert_type: string;
  severity: string;
  message: string;
  is_resolved: boolean;
}
