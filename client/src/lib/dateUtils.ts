import { DateTime, Duration } from "luxon";

// Application timezone (same as backend: America/Chicago)
export const APP_TIMEZONE = "America/Chicago";

/**
 * Get current time in the application timezone
 */
export function now(): DateTime {
  return DateTime.now().setZone(APP_TIMEZONE);
}

/**
 * Get current Unix timestamp (seconds since epoch)
 */
export function nowTimestamp(): number {
  return Math.floor(Date.now() / 1000);
}

/**
 * Parse a backend date string (YYYY-MM-DD HH:mm:ss) as Chicago time
 */
export function parseBackendDate(dateString: string | null | undefined): DateTime | null {
  if (!dateString) return null;
  
  // Parse the date string as Chicago time
  const dt = DateTime.fromFormat(dateString, "yyyy-MM-dd HH:mm:ss", { zone: APP_TIMEZONE });
  return dt.isValid ? dt : null;
}

/**
 * Create DateTime from Unix timestamp
 */
export function fromTimestamp(timestamp: number | null | undefined): DateTime | null {
  if (!timestamp) return null;
  return DateTime.fromSeconds(timestamp).setZone(APP_TIMEZONE);
}

/**
 * Format a date for display
 * @param date - Unix timestamp, date string, or DateTime object
 * @param format - Luxon format string (default: "MMM d, yyyy 'at' h:mm a")
 */
export function formatDate(
  date: number | string | DateTime | null | undefined,
  format: string = "MMM d, yyyy 'at' h:mm a"
): string {
  if (date === null || date === undefined) return "--";
  
  let dt: DateTime;
  
  if (typeof date === "number") {
    // Unix timestamp
    dt = DateTime.fromSeconds(date).setZone(APP_TIMEZONE);
  } else if (typeof date === "string") {
    // Backend date string
    dt = DateTime.fromFormat(date, "yyyy-MM-dd HH:mm:ss", { zone: APP_TIMEZONE });
  } else {
    // Already a DateTime
    dt = date.setZone(APP_TIMEZONE);
  }
  
  if (!dt.isValid) return "--";
  
  return dt.toFormat(format);
}

/**
 * Format a date with relative time (e.g., "2 hours ago", "in 3 days")
 */
export function formatRelative(
  date: number | string | DateTime | null | undefined
): string {
  if (date === null || date === undefined) return "--";
  
  let dt: DateTime;
  
  if (typeof date === "number") {
    dt = DateTime.fromSeconds(date).setZone(APP_TIMEZONE);
  } else if (typeof date === "string") {
    dt = DateTime.fromFormat(date, "yyyy-MM-dd HH:mm:ss", { zone: APP_TIMEZONE });
  } else {
    dt = date.setZone(APP_TIMEZONE);
  }
  
  if (!dt.isValid) return "--";
  
  return dt.toRelative() || "--";
}

/**
 * Calculate election status based on timestamps
 * This should match the backend logic exactly
 */
export function calculateElectionStatus(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  status?: string
): "Open" | "Upcoming" | "Closed" {
  if (status === "closed" || status === "archived") {
    return "Closed";
  }
  
  const nowTs = nowTimestamp();
  
  // Check if election hasn't started yet
  if (startTimestamp && startTimestamp > nowTs) {
    return "Upcoming";
  }
  
  // Check if election has ended
  if (endTimestamp && endTimestamp < nowTs) {
    return "Closed";
  }
  
  // Check if election is currently open
  if (startTimestamp && endTimestamp && startTimestamp <= nowTs && endTimestamp >= nowTs) {
    return "Open";
  }
  
  return "Closed";
}

/**
 * Get time remaining until election ends
 */
export function getTimeRemaining(endTimestamp: number | null | undefined): string | null {
  if (!endTimestamp) return null;
  
  const nowTs = nowTimestamp();
  const diff = endTimestamp - nowTs;
  
  if (diff <= 0) return "Ended";
  
  const duration = Duration.fromObject({ seconds: diff });
  const days = Math.floor(duration.as("days"));
  const hours = Math.floor(duration.as("hours") % 24);
  const minutes = Math.floor(duration.as("minutes") % 60);
  
  if (days > 0) return `${days} day${days > 1 ? "s" : ""} remaining`;
  if (hours > 0) return `${hours} hour${hours > 1 ? "s" : ""} remaining`;
  return `${minutes} minute${minutes > 1 ? "s" : ""} remaining`;
}

/**
 * Get time until election starts
 */
export function getTimeUntilStart(startTimestamp: number | null | undefined): string | null {
  if (!startTimestamp) return null;
  
  const nowTs = nowTimestamp();
  const diff = startTimestamp - nowTs;
  
  if (diff <= 0) return "Started";
  
  const duration = Duration.fromObject({ seconds: diff });
  const days = Math.floor(duration.as("days"));
  const hours = Math.floor(duration.as("hours") % 24);
  const minutes = Math.floor(duration.as("minutes") % 60);
  
  if (days > 0) return `Starts in ${days} day${days > 1 ? "s" : ""}`;
  if (hours > 0) return `Starts in ${hours} hour${hours > 1 ? "s" : ""}`;
  return `Starts in ${minutes} minute${minutes > 1 ? "s" : ""}`;
}

/**
 * Check if an election is currently open for voting
 */
export function isElectionOpen(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  status?: string
): boolean {
  return calculateElectionStatus(startTimestamp, endTimestamp, status) === "Open";
}

/**
 * Check if an election is upcoming
 */
export function isElectionUpcoming(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  status?: string
): boolean {
  return calculateElectionStatus(startTimestamp, endTimestamp, status) === "Upcoming";
}

/**
 * Check if an election is closed
 */
export function isElectionClosed(
  startTimestamp: number | null | undefined,
  endTimestamp: number | null | undefined,
  status?: string
): boolean {
  return calculateElectionStatus(startTimestamp, endTimestamp, status) === "Closed";
}
