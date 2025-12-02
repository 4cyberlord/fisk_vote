"use client";

import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/axios";

export type PublicElectionStatus = "Open" | "Upcoming" | "Closed" | "Active" | string;

export interface PublicElection {
  id: number;
  title: string;
  description: string | null;
  type: string;
  start_time: string | null;
  end_time: string | null;
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
      return response.data;
    },
    staleTime: 2 * 60 * 1000, // 2 minutes
    retry: 1,
  });
}


