import { api } from "../api/axios";

export const alertService = {
  getAll: async () => {
    const response =
      await api.get("/alerts");

    return response.data;
  },

  getActive: async () => {
    const response =
      await api.get("/alerts/active");

    return response.data;
  },

  resolve: async (
    alertId: string
  ) => {
    const response =
      await api.patch(
        `/alerts/${alertId}/resolve`,
        {}
      );

    return response.data;
  },
};
