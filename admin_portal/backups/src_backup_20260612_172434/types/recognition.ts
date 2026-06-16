export interface RecognitionLog {
  id: string;
  employee_id: string;
  kiosk_id: string;
  confidence_score: number;
  event_time: string;
  image_url?: string | null;
}
