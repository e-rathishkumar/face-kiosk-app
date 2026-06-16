import { api } from "../api/axios";

export const unrecognizedService = {
  getAll: async () => {
    const response =
      await api.get("/unrecognized");

    return response.data;
  },

  updateStatus: async (
    id: string,
    status: string
  ) => {
    const response =
      await api.patch(
        `/unrecognized/${id}/status`,
        { status }
      );

    return response.data;
  },
};
