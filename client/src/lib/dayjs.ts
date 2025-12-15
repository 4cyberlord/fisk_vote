import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
import duration from "dayjs/plugin/duration";
import relativeTime from "dayjs/plugin/relativeTime";
import customParseFormat from "dayjs/plugin/customParseFormat";

// Extend dayjs with plugins
dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.extend(duration);
dayjs.extend(relativeTime);
dayjs.extend(customParseFormat);

// Application timezone (same as backend: America/Chicago)
export const APP_TIMEZONE = "America/Chicago";

// Set the default timezone for all dayjs operations
dayjs.tz.setDefault(APP_TIMEZONE);

/**
 * Parse a date string from the backend (format: "YYYY-MM-DD HH:mm:ss" in Chicago time)
 * and return a dayjs object in the app timezone.
 */
export function parseBackendDate(dateString: string | null | undefined): dayjs.Dayjs | null {
  if (!dateString) return null;
  
  // Parse the date string as if it's in Chicago timezone
  return dayjs.tz(dateString, "YYYY-MM-DD HH:mm:ss", APP_TIMEZONE);
}

/**
 * Format a date for display, ensuring it's shown in Chicago timezone.
 * 
 * @param date - Date string from backend (YYYY-MM-DD HH:mm:ss or YYYY-MM-DD), Date object, dayjs object, or Unix timestamp
 * @param format - Output format (default: "MMM D, YYYY [at] h:mm A")
 * @returns Formatted date string or "--" if invalid
 */
export function formatDate(
  date: string | number | Date | dayjs.Dayjs | null | undefined,
  format: string = "MMM D, YYYY [at] h:mm A"
): string {
  if (date === null || date === undefined) return "--";
  
  let d: dayjs.Dayjs;
  
  if (typeof date === "number") {
    // Unix timestamp (seconds)
    d = dayjs.unix(date).tz(APP_TIMEZONE);
  } else if (typeof date === "string") {
    // Try parsing with different formats
    if (date.includes(" ")) {
      // Format: "YYYY-MM-DD HH:mm:ss"
      d = dayjs.tz(date, "YYYY-MM-DD HH:mm:ss", APP_TIMEZONE);
    } else if (date.includes("T")) {
      // ISO format
      d = dayjs(date).tz(APP_TIMEZONE);
    } else {
      // Format: "YYYY-MM-DD" (date only)
      d = dayjs.tz(date, "YYYY-MM-DD", APP_TIMEZONE);
    }
  } else if (date instanceof Date) {
    // Convert Date object to Chicago timezone
    d = dayjs(date).tz(APP_TIMEZONE);
  } else {
    // Already a dayjs object, ensure it's in Chicago timezone
    d = date.tz(APP_TIMEZONE);
  }
  
  if (!d.isValid()) return "--";
  
  // Format in Chicago timezone
  return d.format(format);
}

/**
 * Get current time in Chicago timezone
 */
export function nowInAppTimezone(): dayjs.Dayjs {
  return dayjs().tz(APP_TIMEZONE);
}

/**
 * Calculate duration between two dates
 */
export function getDuration(
  startDate: string | dayjs.Dayjs,
  endDate: string | dayjs.Dayjs
): duration.Duration {
  const start = typeof startDate === "string" 
    ? dayjs.tz(startDate, "YYYY-MM-DD HH:mm:ss", APP_TIMEZONE)
    : startDate;
  const end = typeof endDate === "string"
    ? dayjs.tz(endDate, "YYYY-MM-DD HH:mm:ss", APP_TIMEZONE)
    : endDate;
  
  return dayjs.duration(end.diff(start));
}

export default dayjs;
