import axios from "axios";
import toast from "react-hot-toast";

export const api = axios.create({
  baseURL:
    import.meta.env.VITE_API_URL,
  headers: {
    "Content-Type":
      "application/json",
  },
});

api.interceptors.request.use(
  (config) => {
    const token =
      localStorage.getItem(
        "token"
      );

    if (token) {
      config.headers.Authorization =
        `Bearer ${token}`;
    }

    return config;
  }
);

api.interceptors.response.use(
  (response) => response,

  (error) => {
    const message =
      error?.response?.data
        ?.detail ||
      error?.message ||
      "Unexpected error";

    toast.error(
      Array.isArray(message)
        ? "Validation Error"
        : String(message)
    );

    if (
      error?.response?.status ===
      401
    ) {
      localStorage.removeItem(
        "token"
      );

      window.location.href =
        "/login";
    }

    return Promise.reject(
      error
    );
  }
);
