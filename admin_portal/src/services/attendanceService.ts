import { api } from "../api/axios";

export const attendanceService = {
  getAll: async () => {
    const response =
      await api.get(
        "/attendance"
      );

    return response.data;
  },

  getActive: async () => {
    const response =
      await api.get(
        "/attendance/active"
      );

    return response.data;
  },
};
