export interface SystemMonitorVo {
  huiVersion: string;
  cpuPercent: number;
  diskPercent: number;
  memPercent: number;
}

export interface Hysteria2MonitorVo {
  userTotal: number;
  deviceTotal: number;
  version: string;
  running: boolean;
}

export interface DashboardVo {
  huiVersion: string;
  cpuPercent: number;
  memPercent: number;
  diskPercent: number;
  uptime: number;
  serverTime: number;
  userTotal: number;
  deviceTotal: number;
  version: string;
  running: boolean;
  totalDownload: number;
  totalUpload: number;
  totalUsers: number;
}

export interface OnlineUserVo {
  username: string;
  deviceCount: number;
  download: number;
  upload: number;
}

export interface NetworkInfoVo {
  localIPv4: string;
  publicIPv4: string;
  publicIPv6: string;
}
