import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/axios";

export interface CalendarEvent {
  id: number;
  title: string;
  description: string;
  type: string;
  status: "Upcoming" | "Open" | "Closed";
  color: string;
  start: string;
  end: string;
  start_date: string;
  end_date: string;
  start_time: string;
  end_time: string;
  is_eligible: boolean;
  has_voted: boolean;
  election_type: string;
  is_universal: boolean;
}

export interface CalendarEventsResponse {
  success: boolean;
  message: string;
  data: CalendarEvent[];
  meta: {
    start_date: string;
    end_date: string;
    total_events: number;
  };
}

export interface CalendarEventsParams {
  start_date?: string;
  end_date?: string;
}

export function useCalendarEvents(params: CalendarEventsParams = {}) {
  return useQuery<CalendarEventsResponse>({
    queryKey: ["calendar-events", params],
    queryFn: async () => {
      const response = await api.get<CalendarEventsResponse>("/students/calendar/events", {
        params,
      });
      return response.data;
    },
  });
}

