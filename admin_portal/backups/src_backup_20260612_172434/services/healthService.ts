import { api } from "../api/axios";

export const healthService = {
  getKioskHealth: async () => {
    const response =
      await api.get(
        "/health/kiosks"
      );

    return response.data;
  },
};
