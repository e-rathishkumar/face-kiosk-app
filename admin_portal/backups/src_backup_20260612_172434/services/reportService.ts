import { api } from "../api/axios";

export const reportService = {
  getDashboardReport: async () => {
    const response =
      await api.get(
        "/reports/dashboard"
      );

    return response.data;
  },

  getSchedules: async () => {
    const response =
      await api.get(
        "/report-schedules"
      );

    return response.data;
  },

  createSchedule: async (
    data: any
  ) => {
    const response =
      await api.post(
        "/report-schedules",
        data
      );

    return response.data;
  },

  activateSchedule: async (
    id: string
  ) => {
    const response =
      await api.patch(
        `/report-schedules/${id}/activate`
      );

    return response.data;
  },

  deactivateSchedule: async (
    id: string
  ) => {
    const response =
      await api.patch(
        `/report-schedules/${id}/deactivate`
      );

    return response.data;
  },

  getHistory: async () => {
    const response =
      await api.get(
        "/report-history"
      );

    return response.data;
  },

  runScheduler: async () => {
    const response =
      await api.post(
        "/report-scheduler/run"
      );

    return response.data;
  },
};
