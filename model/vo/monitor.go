package vo

type SystemMonitorVo struct {
	HUIVersion  string  `json:"huiVersion"`
	CpuPercent  float64 `json:"cpuPercent"`
	MemPercent  float64 `json:"memPercent"`
	DiskPercent float64 `json:"diskPercent"`
}

type Hysteria2MonitorVo struct {
	UserTotal   int64  `json:"userTotal"`   // Online users count
	DeviceTotal int64  `json:"deviceTotal"` // Online devices count
	Version     string `json:"version"`     // Version
	Running     bool   `json:"running"`     // Running status
}
