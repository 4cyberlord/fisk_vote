"use client";

import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/axios";
import { setServerTime } from "@/lib/timeService";

export type PublicElectionStatus = "Open" | "Upcoming" | "Closed" | "Active" | string;

export interface PublicElection {
  id: number;
  title: string;
  description: string | null;
  type: string;
  start_time: string | null;
  end_time: string | null;
  start_timestamp: number | null; // Unix timestamp
  end_timestamp: number | null;   // Unix timestamp
  status: string | null;
  current_status: PublicElectionStatus;
  positions_count: number;
  candidates_count: number;
}

export interface PublicElectionsResponseMeta {
  total: number;
  open: number;
  upcoming: number;
  closed: number;
  timestamp: string;
  server_time: number; // Unix timestamp
}

export interface PublicElectionsResponse {
  success: boolean;
  message: string;
  data: PublicElection[];
  meta: PublicElectionsResponseMeta;
}

export function usePublicElections() {
  return useQuery<PublicElectionsResponse>({
    queryKey: ["public-elections"],
    queryFn: async () => {
      const response = await api.get<PublicElectionsResponse>("/students/public/elections");
      const payload = response.data;
      // Align client clock with authoritative server time when provided
      setServerTime(payload?.meta?.server_time);
      return payload;
    },
    staleTime: 30 * 1000, // 30 seconds - refresh frequently to catch status changes
    refetchInterval: 60 * 1000, // Refetch every minute
    retry: 1,
  });
}


