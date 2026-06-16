import { api } from "../api/axios";

export const kioskService = {
  getAll: async () => {
    const response =
      await api.get(
        "/kiosks"
      );

    return response.data;
  },

  getHealth: async () => {
    const response =
      await api.get(
        "/health/kiosks"
      );

    return response.data;
  },

  create: async (
    data: any
  ) => {
    const response =
      await api.post(
        "/kiosks",
        data
      );

    return response.data;
  },

  update: async (
    id: string,
    data: any
  ) => {
    const response =
      await api.put(
        `/kiosks/${id}`,
        data
      );

    return response.data;
  },

  deactivate: async (
    id: string
  ) => {
    const response =
      await api.patch(
        `/kiosks/${id}/deactivate`
      );

    return response.data;
  },
};
