import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/axios";

export interface UserSession {
  id: number;
  jti: string;
  ip_address: string | null;
  device_type: string | null;
  browser: string | null;
  device_info: string;
  location: string | null;
  is_current: boolean;
  last_activity: string;
  last_activity_human: string;
  created_at: string;
  created_at_human: string;
}

export interface SessionsResponse {
  success: boolean;
  message: string;
  data: UserSession[];
}

export function useSessions() {
  return useQuery<SessionsResponse>({
    queryKey: ["sessions"],
    queryFn: async () => {
      const response = await api.get<SessionsResponse>("/students/me/sessions");
      return response.data;
    },
  });
}

export function useRevokeSession() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (jti: string) => {
      const response = await api.delete(`/students/me/sessions/${jti}`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["sessions"] });
    },
  });
}

export function useRevokeAllOtherSessions() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      const response = await api.delete("/students/me/sessions/others");
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["sessions"] });
    },
  });
}

export function useRevokeAllSessions() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      const response = await api.delete("/students/me/sessions/all");
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["sessions"] });
    },
  });
}

