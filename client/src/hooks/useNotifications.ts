import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  getNotifications,
  getUnreadCount,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  type Notification,
  type NotificationsResponse,
  type UnreadCountResponse,
} from "@/services/notificationService";

/**
 * Hook to fetch user notifications
 */
export function useNotifications(params?: {
  unread_only?: boolean;
  urgent_only?: boolean;
}) {
  return useQuery<NotificationsResponse>({
    queryKey: ["notifications", params],
    queryFn: () => getNotifications(params),
    staleTime: 30 * 1000, // 30 seconds - notifications change frequently
    refetchInterval: 60 * 1000, // Refetch every minute
  });
}

/**
 * Hook to fetch unread notification count
 */
export function useUnreadCount() {
  return useQuery<UnreadCountResponse>({
    queryKey: ["notifications", "unread-count"],
    queryFn: getUnreadCount,
    staleTime: 30 * 1000, // 30 seconds
    refetchInterval: 60 * 1000, // Refetch every minute
  });
}

/**
 * Hook to mark a notification as read
 */
export function useMarkAsRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: markNotificationAsRead,
    onSuccess: () => {
      // Invalidate notifications queries to refetch
      queryClient.invalidateQueries({ queryKey: ["notifications"] });
    },
  });
}

/**
 * Hook to mark all notifications as read
 */
export function useMarkAllAsRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: markAllNotificationsAsRead,
    onSuccess: () => {
      // Invalidate notifications queries to refetch
      queryClient.invalidateQueries({ queryKey: ["notifications"] });
    },
  });
}
