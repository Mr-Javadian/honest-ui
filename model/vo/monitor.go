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

type DashboardVo struct {
	HUIVersion    string  `json:"huiVersion"`
	CpuPercent    float64 `json:"cpuPercent"`
	MemPercent    float64 `json:"memPercent"`
	DiskPercent   float64 `json:"diskPercent"`
	Uptime        uint64  `json:"uptime"`
	UserTotal     int64   `json:"userTotal"`
	DeviceTotal   int64   `json:"deviceTotal"`
	Version       string  `json:"version"`
	Running       bool    `json:"running"`
	TotalDownload int64   `json:"totalDownload"`
	TotalUpload   int64   `json:"totalUpload"`
	TotalUsers    int64   `json:"totalUsers"`
}

type OnlineUserVo struct {
	Username    string `json:"username"`
	DeviceCount int64  `json:"deviceCount"`
	Download    int64  `json:"download"`
	Upload      int64  `json:"upload"`
}
