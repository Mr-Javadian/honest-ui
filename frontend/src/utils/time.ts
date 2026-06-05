/**
 * Convert timestamp to formatted date-time string (YYYY-MM-DD HH:mm:ss)
 * @param timestamp Timestamp
 * @returns Formatted date-time string
 */
export const timestampToDateTime = (timestamp: number): string => {
  const date = new Date(timestamp);
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const seconds = date.getSeconds().toString().padStart(2, "0");

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};

export const calculateTimeDifference = (timestamp: number): string => {
  const now = Date.now();
  const diff = timestamp - now;

  if (diff <= 0) {
    return "-";
  }

  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  const remainingHours = hours % 24;
  const remainingMinutes = minutes % 60;
  const remainingSeconds = seconds % 60;

  const parts: string[] = [];

  if (days > 0) {
    parts.push(`${days}d`);
  }
  if (remainingHours > 0) {
    parts.push(`${remainingHours}h`);
  }
  if (remainingMinutes > 0) {
    parts.push(`${remainingMinutes}m`);
  }
  if (remainingSeconds > 0) {
    parts.push(`${remainingSeconds}s`);
  }

  return parts.join(" ");
};

/**
 * Get timestamp one hour later
 * @returns Timestamp one hour later
 */
export const getHourLater = (): number => {
  const date = new Date();
  date.setHours(date.getHours() + 1);
  return date.getTime();
};

/**
 * Get timestamp one day later
 * @returns Timestamp one day later
 */
export const getDayLater = (): number => {
  const date = new Date();
  date.setDate(date.getDate() + 1);
  return date.getTime();
};

/**
 * Get timestamp one week later
 * @returns Timestamp one week later
 */
export const getWeekLater = (): number => {
  const date = new Date();
  date.setDate(date.getDate() + 7);
  return date.getTime();
};

/**
 * Get timestamp one month later
 * @returns Timestamp one month later
 */
export const getMonthLater = (): number => {
  const date = new Date();
  date.setMonth(date.getMonth() + 1);
  return date.getTime();
};

/**
 * Get timestamp one year later
 * @returns Timestamp one year later
 */
export const getYearLater = (): number => {
  const date = new Date();
  date.setFullYear(date.getFullYear() + 1);
  return date.getTime();
};
