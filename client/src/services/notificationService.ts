import axios from "@/lib/axios";

export interface Notification {
  id: number;
  type: 'new_election' | 'upcoming' | 'closing_soon' | 'vote_confirmed' | 'results_available';
  title: string;
  message: string;
  icon: string;
  color: string;
  href: string | null;
  urgent: boolean;
  is_read: boolean;
  read_at: string | null;
  metadata: Record<string, any> | null;
  created_at: string;
  time: string;
}

export interface NotificationsResponse {
  success: boolean;
  data: Notification[];
  meta: {
    unread_count: number;
    total_unread: number;
  };
}

export interface UnreadCountResponse {
  success: boolean;
  data: {
    urgent_count: number;
    total_count: number;
  };
}

/**
 * Get all notifications for the authenticated user
 */
export async function getNotifications(params?: {
  unread_only?: boolean;
  urgent_only?: boolean;
}): Promise<NotificationsResponse> {
  const response = await axios.get("/students/notifications", { params });
  return response.data;
}

/**
 * Get unread notification count
 */
export async function getUnreadCount(): Promise<UnreadCountResponse> {
  const response = await axios.get("/students/notifications/unread-count");
  return response.data;
}

/**
 * Mark a notification as read
 */
export async function markNotificationAsRead(notificationId: number): Promise<void> {
  await axios.post(`/students/notifications/${notificationId}/read`);
}

/**
 * Mark all notifications as read
 */
export async function markAllNotificationsAsRead(): Promise<void> {
  await axios.post("/students/notifications/read-all");
}
