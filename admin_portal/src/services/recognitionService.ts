import { api } from "../api/axios";

export const recognitionService = {
  getAll: async () => {
    const response =
      await api.get(
        "/recognition-logs"
      );

    return response.data;
  },

  getEmployeeLogs: async (
    employeeId: string
  ) => {
    const response =
      await api.get(
        `/recognition-logs/${employeeId}`
      );

    return response.data;
  },
};
