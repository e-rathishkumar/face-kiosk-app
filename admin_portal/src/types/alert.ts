export interface Alert {
  id: string;
  kiosk_id: string;
  alert_type:
    | "LOW_BATTERY"
    | "CRITICAL_BATTERY"
    | "HIGH_CPU"
    | "HIGH_TEMPERATURE"
    | "LOW_STORAGE"
    | "OFFLINE";

  severity:
    | "LOW"
    | "MEDIUM"
    | "HIGH"
    | "CRITICAL";

  message: string;

  is_resolved: boolean;

  resolved_by?: string | null;
  resolved_at?: string | null;
}
