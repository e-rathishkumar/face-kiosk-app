import { api } from "../api/axios";

export const employeeService = {
  getAll: async () => {
    const response =
      await api.get(
        "/employees"
      );

    return response.data;
  },

  getById: async (
    id: string
  ) => {
    const response =
      await api.get(
        `/employees/${id}`
      );

    return response.data;
  },

  create: async (
    data: any
  ) => {
    const response =
      await api.post(
        "/employees",
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
        `/employees/${id}`,
        data
      );

    return response.data;
  },

  deactivate: async (
    id: string
  ) => {
    const response =
      await api.patch(
        `/employees/${id}/deactivate`
      );

    return response.data;
  },

  delete: async (
    id: string
  ) => {
    const response =
      await api.delete(
        `/employees/${id}`
      );

    return response.data;
  },

  uploadFace: async (
    employeeId: string,
    pose: string,
    file: File
  ) => {
    const formData =
      new FormData();

    formData.append(
      "employee_id",
      employeeId
    );

    formData.append(
      "pose",
      pose
    );

    formData.append(
      "image",
      file
    );

    const response =
      await api.post(
        "/employee-faces/upload",
        formData,
        {
          headers: {
            "Content-Type":
              "multipart/form-data",
          },
        }
      );

    return response.data;
  },
};
