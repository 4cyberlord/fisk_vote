import axios, { AxiosError, InternalAxiosRequestConfig } from "axios";
import Cookies from "js-cookie";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000";

// Create axios instance - Production-ready configuration
// Based on: Axios in Next.js Best Practices Guide
export const api = axios.create({
  baseURL: `${BACKEND_URL}/api/v1`,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
  withCredentials: true, // CRITICAL: Required for cookies to work properly
  timeout: 15000, // 15 seconds - prevents hanging requests
});

// Request interceptor - Add JWT token to requests
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = Cookies.get("auth_token");
    
    // Only add token if it exists (login requests won't have a token)
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // Only log login requests in development
    if (process.env.NODE_ENV === "development" && config.url?.includes("login")) {
      const requestData = config.data ? JSON.parse(JSON.stringify(config.data)) : {};
      // Mask password in logs
      if (requestData.password) {
        requestData.password = "***MASKED***";
      }
      console.log("🌐 [AXIOS] REQUEST:", {
        method: config.method?.toUpperCase(),
        url: `${config.baseURL}${config.url}`,
        data: requestData,
      });
    }
    
    return config;
  },
  (error) => {
    if (process.env.NODE_ENV === "development") {
      console.error("Request interceptor error:", error);
    }
    return Promise.reject(error);
  }
);

// Response interceptor - Handle token refresh and errors
api.interceptors.response.use(
  (response) => {
    // Only log login responses in development
    if (process.env.NODE_ENV === "development" && response.config.url?.includes("login")) {
      console.log("🌐 [AXIOS] RESPONSE:", {
        status: response.status,
        url: `${response.config.baseURL}${response.config.url}`,
        data: response.data,
      });
    }
    return response;
  },
  async (error: AxiosError) => {
    // CRITICAL: Handle CORS errors specifically
    if (error.code === 'ERR_NETWORK' || error.message === 'Network Error') {
      if (process.env.NODE_ENV === "development") {
        console.error("[AXIOS] Network Error:", {
          message: error.message,
          url: error.config?.url,
        });
      }
      
      // Return a more descriptive error
      return Promise.reject({
        ...error,
        message: "Network error. Please check your connection and ensure the backend server is running.",
        isCorsError: true,
      });
    }
    
    // Only log login errors in development
    if (process.env.NODE_ENV === "development" && error.config?.url?.includes("login")) {
      console.error("🌐 [AXIOS] ERROR:", {
        status: error.response?.status,
        url: `${error.config.baseURL}${error.config.url}`,
        message: error.response?.data?.message || error.message,
      });
    }
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    // Handle 401 Unauthorized (token expired or invalid)
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      // Try to refresh token
      const refreshToken = Cookies.get("auth_token");
      
      if (refreshToken) {
        try {
                const response = await axios.post(
                  `${BACKEND_URL}/api/v1/students/refresh`,
                  {},
                  {
                    headers: {
                      Authorization: `Bearer ${refreshToken}`,
                      Accept: "application/json",
                    },
                  }
                );

                // Backend returns 'token' not 'access_token'
                const newToken = response.data.data.token || response.data.data.access_token;
                
                if (newToken) {
                  // Validate token format before storing
                  const tokenParts = newToken.split(".");
                  if (tokenParts.length !== 3) {
                    throw new Error("Invalid token format received from refresh");
                  }
                  
                  // Save new token
                  Cookies.set("auth_token", newToken, {
                    expires: 1, // 24 hours (1 day)
                    secure: process.env.NODE_ENV === "production",
                    sameSite: "strict",
                    path: "/", // Ensure cookie is available on all paths
                  });

                  // Retry original request with new token
                  if (originalRequest.headers) {
                    originalRequest.headers.Authorization = `Bearer ${newToken}`;
                  }
            
            return api(originalRequest);
          }
        } catch (refreshError) {
          // Refresh failed - clear token and redirect to login
          Cookies.remove("auth_token");
          
          if (typeof window !== "undefined") {
            window.location.href = "/login";
          }
          
          return Promise.reject(refreshError);
        }
      } else {
        // No token - redirect to login
        Cookies.remove("auth_token");
        
        if (typeof window !== "undefined") {
          window.location.href = "/login";
        }
      }
    }

    return Promise.reject(error);
  }
);

export default api;

