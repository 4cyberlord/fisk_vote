import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/axios";

export interface AuditLog {
  id: number;
  action_type: string;
  action_description: string;
  event_type: string | null;
  status: "success" | "failed" | "pending";
  icon: string;
  color: string;
  badge: string;
  ip_address: string | null;
  user_agent: string | null;
  device: string | null;
  browser: string | null;
  location: string | null;
  request_url: string | null;
  request_method: string | null;
  changes_summary: string | null;
  old_values: Record<string, unknown> | null;
  new_values: Record<string, unknown> | null;
  error_message: string | null;
  metadata: Record<string, unknown> | null;
  created_at: string;
  created_at_human: string;
  created_at_formatted: string;
}

export interface AuditLogsResponse {
  success: boolean;
  message: string;
  data: AuditLog[];
  meta: {
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    from: number | null;
    to: number | null;
  };
  statistics: {
    successful_logins: number;
    failed_attempts: number;
    unique_ips: number;
    total_activities: number;
  };
}

export interface AuditLogsParams {
  page?: number;
  per_page?: number;
  action_type?: "login" | "logout" | "create" | "update" | "delete" | "view" | "access";
  status?: "success" | "failed" | "pending";
  date_from?: string;
  date_to?: string;
}

export function useAuditLogs(params: AuditLogsParams = {}) {
  return useQuery<AuditLogsResponse>({
    queryKey: ["audit-logs", params],
    queryFn: async () => {
      const response = await api.get<AuditLogsResponse>("/students/me/audit-logs", {
        params,
      });
      return response.data;
    },
  });
}

