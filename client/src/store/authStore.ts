import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import { jwtDecode } from "jwt-decode";
import Cookies from "js-cookie";

interface User {
  id: number;
  email: string;
  name: string;
  first_name: string;
  last_name: string;
  middle_initial?: string | null;
  student_id?: string | null;
  email_verified_at?: string | null;
  
  // Additional email fields
  university_email?: string | null;
  personal_email?: string | null;
  
  // Academic information
  department?: string | null;
  major?: string | null;
  class_level?: string | null;
  enrollment_status?: string | null;
  student_type?: string | null;
  citizenship_status?: string | null;
  
  // Contact information
  phone_number?: string | null;
  address?: string | null;
  
  // Profile
  profile_photo?: string | null;
  
  // Roles
  roles?: string[];
  
  // Organizations
  organizations?: Array<{ id: number; name: string }> | string[];
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  
  // Actions
  setAuth: (token: string, user: User) => void;
  setUser: (user: User) => void;
  logout: () => void;
  checkAuth: () => boolean;
  getDecodedToken: () => any | null;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,

      setAuth: (token: string, user: User) => {
        // Validate token format before storing
        if (!token || typeof token !== "string") {
          console.error("setAuth: Invalid token provided");
          return;
        }
        
        // Validate JWT format
        const tokenParts = token.split(".");
        if (tokenParts.length !== 3) {
          console.error("setAuth: Invalid JWT format - token must have 3 parts");
          return;
        }
        
        // Store token in cookie for axios interceptor
        Cookies.set("auth_token", token, {
          expires: 1, // 24 hours (1 day)
          secure: process.env.NODE_ENV === "production",
          sameSite: "strict",
          path: "/", // Ensure cookie is available on all paths
        });

        set({
          token,
          user,
          isAuthenticated: true,
          isLoading: false,
        });
      },

      setUser: (user: User) => {
        set({ user });
      },

      logout: () => {
        // Remove token from cookie
        Cookies.remove("auth_token");

        set({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
        });
      },

      checkAuth: () => {
        const token = Cookies.get("auth_token");
        
        if (!token) {
          get().logout();
          return false;
        }

        try {
          const decoded = jwtDecode(token);
          const currentTime = Date.now() / 1000;

          // Check if token is expired
          if (decoded.exp && decoded.exp < currentTime) {
            get().logout();
            return false;
          }

          // Token is valid
          if (!get().isAuthenticated) {
            set({ isAuthenticated: true });
          }

          return true;
        } catch (error) {
          // Invalid token
          get().logout();
          return false;
        }
      },

      getDecodedToken: () => {
        const token = Cookies.get("auth_token");
        
        if (!token) {
          return null;
        }

        try {
          return jwtDecode(token);
        } catch (error) {
          return null;
        }
      },
    }),
    {
      name: "auth-storage",
      storage: createJSONStorage(() => ({
        getItem: (name: string) => {
          if (typeof window === "undefined") return null;
          return localStorage.getItem(name);
        },
        setItem: (name: string, value: string) => {
          if (typeof window === "undefined") return;
          localStorage.setItem(name, value);
        },
        removeItem: (name: string) => {
          if (typeof window === "undefined") return;
          localStorage.removeItem(name);
        },
      })),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

