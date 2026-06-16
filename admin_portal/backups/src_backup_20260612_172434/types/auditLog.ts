export interface AuditLog {
  id: string;
  user_id?: string | null;
  action: string;
  entity_type: string;
  entity_id: string;
  old_value?: string | null;
  new_value?: string | null;
  ip_address?: string | null;
}
