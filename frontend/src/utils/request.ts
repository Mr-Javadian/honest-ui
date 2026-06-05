import axios, { InternalAxiosRequestConfig, AxiosResponse } from "axios";
import { useAccountStoreHook } from "@/store/modules/account";

const dynamicBase = (window as any).__dynamic_base__ || "";
// Create axios instance
const service = axios.create({
  baseURL: `${dynamicBase}${import.meta.env.VITE_APP_BASE_API}`,
  timeout: 50000,
  headers: { "Content-Type": "application/json;charset=utf-8" },
});

// Request interceptor
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const accountStore = useAccountStoreHook();
    if (accountStore.token) {
      config.headers.Authorization = accountStore.token;
    }
    return config;
  },
  (error: any) => {
    return Promise.reject(error);
  }
);

// Response interceptor
service.interceptors.response.use(
  (response: AxiosResponse) => {
    const { code, message } = response.data;
    if (code === 20000) {
      return response.data;
    }
    // Handle binary stream response (file export)
    if (response.data instanceof ArrayBuffer || response.data instanceof Blob) {
      return response;
    }

    ElMessage.error(message || "System error");
    return Promise.reject(new Error(message || "Error"));
  },
  (error: any) => {
    if (error.response.data) {
      const { code, msg } = error.response.data;
      // Token expired, re-login
      if (code === "A0230") {
        ElMessageBox.confirm("当前页面已失效，请重新登录", "提示", {
          confirmButtonText: "确定",
          type: "warning",
        }).then(() => {
          localStorage.clear();
          window.location.href = "/";
        });
      } else {
        ElMessage.error(msg || "System error");
      }
    }
    return Promise.reject(error.message);
  }
);

// Export axios instance
export default service;
