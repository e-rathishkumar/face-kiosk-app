import { api } from "../api/axios";

export const dashboardAlertService = {
  getActiveAlerts: async () => {
    const response =
      await api.get(
        "/alerts/active"
      );

    return response.data;
  },
};
