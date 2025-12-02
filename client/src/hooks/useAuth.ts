"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/authStore";
import { authService, LoginCredentials } from "@/services/authService";
import toast from "react-hot-toast";
import Cookies from "js-cookie";

/**
 * Hook to access auth store
 */
export function useAuth() {
  const store = useAuthStore();
  return store;
}

/**
 * Hook for login mutation
 */
export function useLogin() {
  const router = useRouter();
  const { setAuth } = useAuthStore();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (credentials: LoginCredentials) => {
      return await authService.login(credentials);
    },
    onSuccess: async (data) => {
      // Validate token format before storing
      // Backend returns 'token' not 'access_token'
      const token = data.data.token || data.data.access_token;
      
      if (!token || typeof token !== "string") {
        console.error("Login: Invalid token received from server");
        toast.error("Login failed: Invalid token received");
        return;
      }
      
      // Validate JWT format (should have 3 parts separated by dots)
      const tokenParts = token.split(".");
      if (tokenParts.length !== 3) {
        console.error("Login: Invalid token format - expected JWT with 3 parts, got:", tokenParts.length);
        console.error("Token preview:", token.substring(0, 50) + "...");
        toast.error("Login failed: Invalid token format");
        return;
      }
      
      // Set auth state (this sets cookie and Zustand store)
      setAuth(token, data.data.user);

      // Invalidate and refetch user queries
      queryClient.invalidateQueries({ queryKey: ["user"] });

      toast.success("Login successful!\nWelcome back.");
      
      // Wait for cookie to be set - ensure it's persisted
      await new Promise(resolve => setTimeout(resolve, 800));
      
      // Double-check cookie is set before redirect
      const tokenCheck = Cookies.get("auth_token");
      console.log("Login: Cookie check after delay:", tokenCheck ? "Found" : "Not found");
      
      if (!tokenCheck) {
        console.error("Login: Cookie not set! Setting it again...");
        // Validate token format before setting again
        const tokenParts = token.split(".");
        if (tokenParts.length === 3) {
          Cookies.set("auth_token", token, {
            expires: 1, // 24 hours (1 day)
            secure: process.env.NODE_ENV === "production",
            sameSite: "strict",
            path: "/",
          });
          await new Promise(resolve => setTimeout(resolve, 300));
        } else {
          console.error("Login: Cannot set cookie - invalid token format");
          toast.error("Login failed: Token format error");
          return;
        }
      }
      
      // Verify one more time and validate format
      const finalCheck = Cookies.get("auth_token");
      console.log("Login: Final cookie check before redirect:", finalCheck ? "Found" : "Not found");
      
      if (finalCheck) {
        const checkParts = finalCheck.split(".");
        if (checkParts.length !== 3) {
          console.error("Login: Cookie contains invalid token format!");
          Cookies.remove("auth_token", { path: "/" });
          toast.error("Login failed: Token corrupted");
          return;
        }
      }
      
      // Use window.location for a full page reload
      // This ensures cookie is definitely available
      if (typeof window !== "undefined") {
        console.log("Login: Redirecting to /dashboard");
        window.location.href = "/dashboard";
      }
    },
    onError: (error: any) => {
      // Error will be handled in the component's onSubmit catch block
      // Don't show toast here to avoid duplicate error messages
      // The form will display the error with red borders and clear messaging
      console.error("Login error:", error);
    },
  });
}

/**
 * Hook for logout mutation
 */
export function useLogout() {
  const router = useRouter();
  const { logout } = useAuthStore();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      return await authService.logout();
    },
    onSuccess: () => {
      // Clear auth state
      logout();

      // Clear all queries
      queryClient.clear();

      toast.success("Logged out successfully.");
      
      // Redirect to login
      router.push("/login");
    },
    onError: (error: any) => {
      // Even if logout fails, clear local state
      logout();
      queryClient.clear();
      router.push("/login");
    },
  });
}

/**
 * Hook to get current user
 */
export function useCurrentUser() {
  const { isAuthenticated } = useAuthStore();

  return useQuery({
    queryKey: ["user", "current"],
    queryFn: async () => {
      return await authService.getCurrentUser();
    },
    enabled: isAuthenticated,
    staleTime: 5 * 60 * 1000, // 5 minutes
    retry: 1,
  });
}

/**
 * Hook to refresh token
 */
export function useRefreshToken() {
  const { setAuth, user } = useAuthStore();

  return useMutation({
    mutationFn: async () => {
      return await authService.refreshToken();
    },
          onSuccess: (data) => {
            // Update token in store
            // Backend returns 'token' not 'access_token'
            const token = data.token || data.access_token;
            if (user && token) {
              setAuth(token, user);
            }
          },
    onError: () => {
      // Refresh failed - logout user
      useAuthStore.getState().logout();
    },
  });
}

