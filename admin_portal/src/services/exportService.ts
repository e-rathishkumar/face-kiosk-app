import { api } from "../api/axios";

export const exportService = {
  attendanceCsv: () =>
    window.open(
      `${api.defaults.baseURL}/exports/attendance/csv`,
      "_blank"
    ),

  attendanceXlsx: () =>
    window.open(
      `${api.defaults.baseURL}/exports/attendance/xlsx`,
      "_blank"
    ),

  recognitionCsv: () =>
    window.open(
      `${api.defaults.baseURL}/exports/recognition/csv`,
      "_blank"
    ),

  recognitionXlsx: () =>
    window.open(
      `${api.defaults.baseURL}/exports/recognition/xlsx`,
      "_blank"
    ),

  unrecognizedCsv: () =>
    window.open(
      `${api.defaults.baseURL}/exports/unrecognized/csv`,
      "_blank"
    ),

  unrecognizedXlsx: () =>
    window.open(
      `${api.defaults.baseURL}/exports/unrecognized/xlsx`,
      "_blank"
    ),
};
