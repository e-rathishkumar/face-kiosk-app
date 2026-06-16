import { api } from "../api/axios";

export const auditLogService = {
  getAll: async () => {
    const response =
      await api.get("/audit-logs");

    return response.data;
  },

  getByEntityType: async (
    entityType: string
  ) => {
    const response =
      await api.get(
        `/audit-logs/${entityType}`
      );

    return response.data;
  },
};
