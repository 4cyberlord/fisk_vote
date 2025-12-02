import { api } from "@/lib/axios";
import { useAuthStore } from "@/store/authStore";

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  data: {
    token: string; // Backend returns 'token' not 'access_token'
    token_type: string;
    expires_in: number;
    user: {
      id: number;
      email: string;
      name: string;
      first_name: string;
      last_name: string;
      email_verified_at: string | null;
    };
  };
}

export interface UserResponse {
  success: boolean;
  message?: string;
  data: {
    // Basic Information
    id: number;
    name: string;
    first_name: string;
    last_name: string;
    middle_initial?: string | null;
    
    // Email Information
    email: string;
    university_email?: string | null;
    personal_email?: string | null;
    email_verified_at: string | null;
    
    // Student Information
    student_id?: string | null;
    department?: string | null;
    major?: string | null;
    class_level?: string | null;
    enrollment_status?: string | null;
    student_type?: string | null;
    citizenship_status?: string | null;
    
    // Contact Information
    phone_number?: string | null;
    address?: string | null;
    
    // Profile Information
    profile_photo?: string | null;
    
    // Account Information
    roles: string[];
    created_at?: string | null;
    updated_at?: string | null;
  };
}

class AuthService {
  /**
   * Login user and get JWT token
   */
  async login(credentials: LoginCredentials): Promise<LoginResponse> {
    // Only log in development
    if (process.env.NODE_ENV === "development") {
      console.log("🔐 [AUTH API] LOGIN REQUEST:", {
        email: credentials.email,
        password: "***MASKED***",
      });
    }
    
    try {
      const response = await api.post<LoginResponse>("/students/login", credentials);
      
      // Only log in development
      if (process.env.NODE_ENV === "development") {
        console.log("✅ [AUTH API] LOGIN SUCCESS:", {
          status: response.status,
          userId: response.data.data?.user?.id,
          userEmail: response.data.data?.user?.email,
        });
      }
      
      return response.data;
    } catch (error: any) {
      // Only log essential error info in development
      if (process.env.NODE_ENV === "development") {
        const status = error.response?.status;
        const message = error.response?.data?.message || error.message;
        console.error("❌ [AUTH API] LOGIN FAILED:", {
          status,
          message,
        });
      }
      throw error;
    }
  }

  /**
   * Logout user (invalidate token)
   */
  async logout(): Promise<void> {
    try {
      await api.post("/students/logout");
    } catch (error) {
      // Even if logout fails on server, clear local state
      console.error("Logout error:", error);
    } finally {
      useAuthStore.getState().logout();
    }
  }

  /**
   * Refresh JWT token
   */
  async refreshToken(): Promise<{ token: string; expires_in: number }> {
    const response = await api.post<{
      success: boolean;
      data: {
        token: string; // Backend returns 'token' not 'access_token'
        token_type: string;
        expires_in: number;
      };
    }>("/students/refresh");
    return {
      token: response.data.data.token,
      expires_in: response.data.data.expires_in,
    };
  }

  /**
   * Get current authenticated user
   */
  async getCurrentUser(): Promise<UserResponse> {
    const response = await api.get<UserResponse>("/students/me");
    return response.data;
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    return useAuthStore.getState().checkAuth();
  }
}

export const authService = new AuthService();

