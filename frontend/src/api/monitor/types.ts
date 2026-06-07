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
  userTotal: number;
  deviceTotal: number;
  version: string;
  running: boolean;
  totalDownload: number;
  totalUpload: number;
  totalUsers: number;
}
