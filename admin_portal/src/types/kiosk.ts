export interface Kiosk {
  id: string;
  kiosk_code: string;
  name: string;
  location?: string | null;
  secret_key: string;
  is_active: boolean;
}

export interface KioskHealth {
  kiosk_id: string;
  kiosk_name: string;
  status: string;
  battery_level?: number | null;
  cpu_usage?: number | null;
  memory_usage?: number | null;
  temperature?: number | null;
  active_alerts: number;
  last_heartbeat?: string | null;
}

export interface CreateKioskRequest {
  kiosk_code: string;
  name: string;
  location?: string;
  secret_key: string;
}

export interface UpdateKioskRequest {
  name: string;
  location?: string;
  is_active: boolean;
}
