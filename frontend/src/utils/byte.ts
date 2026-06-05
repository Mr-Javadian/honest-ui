/**
 * Format bytes size
 * @param bytes Number of bytes
 * @param decimals Number of decimal places, default 2
 * @returns Formatted bytes size string
 */
export const formatBytes = (bytes: number, decimals = 2): string => {
  // Check for special value
  if (bytes === -1) {
    return "Unlimited";
  }
  if (bytes === 0) {
    return "0 Bytes";
  }

  // Calculate units and size
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  // Return formatted string
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i];
};

export const calculateBytes = (value = 0, unit = "Bytes"): number => {
  // Convert unit to uppercase and trim spaces
  const formattedUnit = unit.toUpperCase().trim();

  // Define mapping of storage units to bytes
  const unitToBytes: Record<string, number> = {
    BYTES: 1,
    KB: 1024 ** 1,
    MB: 1024 ** 2,
    GB: 1024 ** 3,
    TB: 1024 ** 4,
    PB: 1024 ** 5,
    EB: 1024 ** 6,
    ZB: 1024 ** 7,
    YB: 1024 ** 8,
  };

  // Check if unit exists in mapping
  if (!Object.prototype.hasOwnProperty.call(unitToBytes, formattedUnit)) {
    throw new Error("Invalid unit");
  }

  if (value == -1) {
    return -1;
  }

  // Calculate and return bytes
  return value * unitToBytes[formattedUnit];
};

/**
 * Format storage capacity value
 * @param bytes Storage capacity (bytes)
 * @param decimals Number of decimal places, default 2
 * @returns Formatted storage capacity value
 */
export const formatStorageCapacity = (bytes: number, decimals = 2): number => {
  // Check if input is valid
  if (!bytes || bytes <= 0) {
    return bytes;
  }

  // Calculate storage unit
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  // Format and return storage capacity value
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm));
};

/**
 * Format storage capacity unit
 * @param bytes Storage capacity (bytes)
 * @returns Formatted storage unit
 */
export const formatStorageUnit = (bytes: number): string => {
  // Check if input is valid
  if (!bytes || bytes <= 0) {
    return "Bytes";
  }

  // Calculate storage unit
  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  // Return formatted storage unit
  return sizes[i];
};
