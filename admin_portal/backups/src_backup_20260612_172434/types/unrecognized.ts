export interface UnrecognizedEntry {
  id: string;
  kiosk_id: string;
  image_url: string;
  face_crop_url: string;
  confidence_score?: number | null;
  status:
    | "PENDING"
    | "VISITOR"
    | "REGISTERED"
    | "IGNORED";
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  remarks?: string | null;
}

export interface UpdateUnrecognizedStatusRequest {
  status:
    | "PENDING"
    | "VISITOR"
    | "REGISTERED"
    | "IGNORED";
}
