/**
 * Time Service - Uses World Time API for accurate Nashville, TN time
 * This ensures election status is calculated correctly regardless of user's local clock
 */

const TIMEZONE = "America/Chicago"; // Nashville, TN timezone
const WORLD_TIME_API_URL = `https://worldtimeapi.org/api/timezone/${TIMEZONE}`;

interface WorldTimeResponse {
  utc_offset: string;
  timezone: string;
  datetime: string;
  utc_datetime: string;
  unixtime: number;
  dst: boolean;
  abbreviation: string;
}

// Cache the time offset between local and server time
let serverTimeOffset: number | null = null;
let lastSync: number = 0;
const SYNC_INTERVAL = 5 * 60 * 1000; // Re-sync every 5 minutes

/**
 * Fetch current time from World Time API for Nashville, TN.
 * Best effort: times out quickly, falls back to local time without throwing.
 */
export async function fetchServerTime(): Promise<number> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 3000);

  try {
    const response = await fetch(WORLD_TIME_API_URL, {
      cache: "no-store",
      mode: "cors",
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch time: ${response.status}`);
    }

    const data: WorldTimeResponse = await response.json();
    if (typeof data?.unixtime !== "number") {
      throw new Error("Invalid time payload");
    }

    const serverTimestamp = data.unixtime;
    const localTimestamp = Math.floor(Date.now() / 1000);
    serverTimeOffset = serverTimestamp - localTimestamp;
    lastSync = Date.now();

    console.debug(
      "[TimeService] Synced World Time API",
      new Date(serverTimestamp * 1000).toISOString(),
      `offset=${serverTimeOffset}s`
    );

    return serverTimestamp;
  } catch (error) {
    // Swallow network/abort errors; fall back quietly
    return Math.floor(Date.now() / 1000);
  } finally {
    clearTimeout(timeout);
  }
}

/**
 * Get current Nashville time as Unix timestamp
 * Uses cached offset if available, otherwise fetches from API
 */
export async function getNashvilleTimestamp(): Promise<number> {
  // If we haven't synced recently, sync now
  if (serverTimeOffset === null || Date.now() - lastSync > SYNC_INTERVAL) {
    return await fetchServerTime();
  }
  
  // Use cached offset to calculate current server time
  return Math.floor(Date.now() / 1000) + serverTimeOffset;
}

/**
 * Get current Nashville time synchronously using cached offset
 * Falls back to local time if not synced yet
 */
export function getNashvilleTimestampSync(): number {
  if (serverTimeOffset === null) {
    return Math.floor(Date.now() / 1000);
  }
  return Math.floor(Date.now() / 1000) + serverTimeOffset;
}

/**
 * Allow consumers to set server time (e.g., from backend meta.server_time)
 * to avoid relying on external fetch when data already provides it.
 */
export function setServerTime(serverTimestamp: number | null | undefined): void {
  if (!serverTimestamp || Number.isNaN(serverTimestamp)) return;
  const localTimestamp = Math.floor(Date.now() / 1000);
  serverTimeOffset = serverTimestamp - localTimestamp;
  lastSync = Date.now();
}

/**
 * Calculate election status based on timestamps
 * Uses Nashville server time for accurate comparison
 */
export function calculateElectionStatus(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  dbStatus?: string
): "Open" | "Upcoming" | "Closed" {
  if (dbStatus === "closed" || dbStatus === "archived") {
    return "Closed";
  }
  
  const nowTimestamp = getNashvilleTimestampSync();
  
  if (!startTimestamp || !endTimestamp) {
    return "Closed";
  }
  
  // Election hasn't started yet
  if (startTimestamp > nowTimestamp) {
    return "Upcoming";
  }
  
  // Election has ended
  if (endTimestamp < nowTimestamp) {
    return "Closed";
  }
  
  // Election is currently open
  return "Open";
}

/**
 * Get time remaining until election ends
 */
export function getTimeRemaining(endTimestamp: number | null | undefined): string | null {
  if (!endTimestamp) return null;
  
  const nowTimestamp = getNashvilleTimestampSync();
  const diff = endTimestamp - nowTimestamp;
  
  if (diff <= 0) return "Ended";
  
  const days = Math.floor(diff / 86400);
  const hours = Math.floor((diff % 86400) / 3600);
  const minutes = Math.floor((diff % 3600) / 60);
  
  if (days > 0) return `${days} day${days > 1 ? "s" : ""} remaining`;
  if (hours > 0) return `${hours} hour${hours > 1 ? "s" : ""} remaining`;
  return `${minutes} minute${minutes > 1 ? "s" : ""} remaining`;
}

/**
 * Get time until election starts
 */
export function getTimeUntilStart(startTimestamp: number | null | undefined): string | null {
  if (!startTimestamp) return null;
  
  const nowTimestamp = getNashvilleTimestampSync();
  const diff = startTimestamp - nowTimestamp;
  
  if (diff <= 0) return "Started";
  
  const days = Math.floor(diff / 86400);
  const hours = Math.floor((diff % 86400) / 3600);
  const minutes = Math.floor((diff % 3600) / 60);
  
  if (days > 0) return `Starts in ${days} day${days > 1 ? "s" : ""}`;
  if (hours > 0) return `Starts in ${hours} hour${hours > 1 ? "s" : ""}`;
  return `Starts in ${minutes} minute${minutes > 1 ? "s" : ""}`;
}

/**
 * Check if election is currently open
 */
export function isElectionOpen(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  dbStatus?: string
): boolean {
  return calculateElectionStatus(startTimestamp, endTimestamp, dbStatus) === "Open";
}

/**
 * Initialize time sync - call this on app start
 */
export function initTimeSync(): void {
  // Initial sync
  fetchServerTime();
  
  // Re-sync periodically
  setInterval(() => {
    fetchServerTime();
  }, SYNC_INTERVAL);
}

// Export timezone info
export const NASHVILLE_TIMEZONE = TIMEZONE;
