import { useEffect, useMemo, useState } from "react";
import dayjs from "@/lib/dayjs";
import { usePublicElections, type PublicElection } from "./usePublicElections";
import { getNashvilleTimestampSync } from "@/lib/timeService";

export type NextElectionState = "upcoming" | "none";

export interface NextElectionResult {
  election: PublicElection | null;
  targetTimestamp: number | null;
  state: NextElectionState;
}

function getStartTimestamp(election: PublicElection): number | null {
  if (typeof election.start_timestamp === "number") return election.start_timestamp;
  if (election.start_time) {
    const parsed = dayjs(election.start_time);
    return parsed.isValid() ? parsed.unix() : null;
  }
  return null;
}

export function findNextElection(
  elections: PublicElection[],
  nowTimestamp: number
): NextElectionResult {
  const upcoming = elections
    .map((election) => ({
      election,
      start: getStartTimestamp(election),
    }))
    .filter((item) => item.start && item.start > nowTimestamp)
    .sort((a, b) => (a.start! - b.start!));

  if (upcoming.length > 0) {
    return {
      election: upcoming[0].election,
      targetTimestamp: upcoming[0].start!,
      state: "upcoming",
    };
  }

  return {
    election: null,
    targetTimestamp: null,
    state: "none",
  };
}

export function useNextElectionCountdown() {
  const { data, isLoading, error, refetch, isFetching } = usePublicElections();
  const [targetTimestamp, setTargetTimestamp] = useState<number | null>(null);
  const [state, setState] = useState<NextElectionState>("none");
  const [countdown, setCountdown] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });

  const nextElection = useMemo(() => {
    const now = getNashvilleTimestampSync();
    if (!data?.data || data.data.length === 0) {
      return { election: null, targetTimestamp: null, state: "none" } as NextElectionResult;
    }
    return findNextElection(data.data, now);
  }, [data?.data]);

  useEffect(() => {
    setTargetTimestamp(nextElection.targetTimestamp);
    setState(nextElection.state);
  }, [nextElection.targetTimestamp, nextElection.state]);

  useEffect(() => {
    if (!targetTimestamp) return;

    const tick = () => {
      const now = getNashvilleTimestampSync();
      const diff = Math.max(targetTimestamp - now, 0);

      const days = Math.floor(diff / 86400);
      const hours = Math.floor((diff % 86400) / 3600);
      const minutes = Math.floor((diff % 3600) / 60);
      const seconds = Math.floor(diff % 60);

      setCountdown({ days, hours, minutes, seconds });

      if (diff === 0) {
        // Once we hit zero, refetch to grab the next upcoming election
        refetch();
      }
    };

    tick();
    const id = window.setInterval(tick, 1000);
    return () => window.clearInterval(id);
  }, [targetTimestamp, refetch]);

  return {
    isLoading: isLoading || isFetching,
    error,
    nextElection: nextElection.election,
    targetTimestamp,
    state,
    countdown,
  };
}

