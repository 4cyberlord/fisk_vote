"use client";

import { useEffect, useState, useCallback } from "react";
import {
  fetchServerTime,
  getNashvilleTimestampSync,
  calculateElectionStatus,
  getTimeRemaining,
  getTimeUntilStart,
  isElectionOpen,
} from "@/lib/timeService";

/**
 * Hook to sync with Nashville server time and provide accurate election status
 */
export function useServerTime() {
  const [isSynced, setIsSynced] = useState(false);
  const [currentTimestamp, setCurrentTimestamp] = useState<number>(
    Math.floor(Date.now() / 1000)
  );

  // Initial sync and periodic updates
  useEffect(() => {
    // Sync with World Time API (best effort; falls back to local time if blocked)
    const sync = async () => {
      try {
        await fetchServerTime();
      } catch (e) {
        // fetchServerTime already falls back silently; we swallow errors here
      } finally {
        setIsSynced(true);
        setCurrentTimestamp(getNashvilleTimestampSync());
      }
    };

    sync();

    // Update current timestamp every second for live countdown
    const interval = setInterval(() => {
      setCurrentTimestamp(getNashvilleTimestampSync());
    }, 1000);

    // Re-sync with API every 5 minutes
    const syncInterval = setInterval(() => {
      fetchServerTime().catch(() => {});
    }, 5 * 60 * 1000);

    return () => {
      clearInterval(interval);
      clearInterval(syncInterval);
    };
  }, []);

  const getElectionStatus = useCallback(
    (
      startTimestamp: number | null | undefined,
      endTimestamp: number | null | undefined,
      dbStatus?: string
    ) => {
      return calculateElectionStatus(startTimestamp, endTimestamp, dbStatus);
    },
    []
  );

  const getElectionTimeRemaining = useCallback(
    (endTimestamp: number | null | undefined) => {
      return getTimeRemaining(endTimestamp);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [currentTimestamp] // Re-calculate when timestamp updates
  );

  const getElectionTimeUntilStart = useCallback(
    (startTimestamp: number | null | undefined) => {
      return getTimeUntilStart(startTimestamp);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [currentTimestamp] // Re-calculate when timestamp updates
  );

  const checkIfElectionOpen = useCallback(
    (
      startTimestamp: number | null | undefined,
      endTimestamp: number | null | undefined,
      dbStatus?: string
    ) => {
      return isElectionOpen(startTimestamp, endTimestamp, dbStatus);
    },
    []
  );

  return {
    isSynced,
    currentTimestamp,
    getElectionStatus,
    getElectionTimeRemaining,
    getElectionTimeUntilStart,
    checkIfElectionOpen,
  };
}

export default useServerTime;
