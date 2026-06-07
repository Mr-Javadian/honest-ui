package service

import (
	"errors"
	"fmt"
	"github.com/Mr-Javadian/honest-ui/dao"
	"github.com/Mr-Javadian/honest-ui/model/constant"
	"github.com/Mr-Javadian/honest-ui/model/entity"
	"github.com/Mr-Javadian/honest-ui/model/vo"
	"github.com/Mr-Javadian/honest-ui/util"
	"regexp"
	"strings"
)

func MonitorSystem() (vo.SystemMonitorVo, error) {
	cpuPercent, err := util.GetCpuPercent()
	if err != nil {
		return vo.SystemMonitorVo{}, errors.New("cpu query failed")
	}
	memPercent, err := util.GetMemPercent()
	if err != nil {
		return vo.SystemMonitorVo{}, errors.New("mem query failed")
	}
	diskPercent, err := util.GetDiskPercent()
	if err != nil {
		return vo.SystemMonitorVo{}, errors.New("disk query failed")
	}
	return vo.SystemMonitorVo{
		HUIVersion:  constant.Version,
		CpuPercent:  cpuPercent,
		MemPercent:  memPercent,
		DiskPercent: diskPercent,
	}, nil
}

func MonitorHysteria2() (vo.Hysteria2MonitorVo, error) {
	var hysteria2MonitorVo vo.Hysteria2MonitorVo
	onlineUsers, err := Hysteria2Online()
	if err != nil {
		return hysteria2MonitorVo, err
	}

	if len(onlineUsers) > 0 {
		hysteria2MonitorVo.UserTotal = int64(len(onlineUsers))
		var deviceTotal int64 = 0
		for _, value := range onlineUsers {
			deviceTotal += value
		}
		hysteria2MonitorVo.DeviceTotal = deviceTotal
	}

	hysteria2MonitorVo.Version = "-"
	content, err := util.Exec(fmt.Sprintf("%s version", util.GetHysteria2BinPath()))
	if err == nil {
		pattern := `v\d+\.\d+\.\d+`
		re := regexp.MustCompile(pattern)
		matches := re.FindAllString(strings.TrimSpace(content), -1)
		if len(matches) > 0 {
			hysteria2MonitorVo.Version = matches[0]
		}
	}

	running := Hysteria2IsRunning()
	hysteria2MonitorVo.Running = running
	return hysteria2MonitorVo, nil
}

func MonitorDashboard() (vo.DashboardVo, error) {
	var dashboardVo vo.DashboardVo
	systemVo, err := MonitorSystem()
	if err != nil {
		return dashboardVo, err
	}
	hotsVo, err := MonitorHysteria2()
	if err != nil {
		return dashboardVo, err
	}
	totalDownload, totalUpload, totalUsers, err := dao.AggregateAccountStats()
	if err != nil {
		return dashboardVo, err
	}
	uptime, err := util.GetUptime()
	if err != nil {
		uptime = 0
	}
	dashboardVo = vo.DashboardVo{
		HUIVersion:    systemVo.HUIVersion,
		CpuPercent:    systemVo.CpuPercent,
		MemPercent:    systemVo.MemPercent,
		DiskPercent:   systemVo.DiskPercent,
		Uptime:        uptime,
		UserTotal:     hotsVo.UserTotal,
		DeviceTotal:   hotsVo.DeviceTotal,
		Version:       hotsVo.Version,
		Running:       hotsVo.Running,
		TotalDownload: totalDownload,
		TotalUpload:   totalUpload,
		TotalUsers:    totalUsers,
	}
	return dashboardVo, nil
}

func MonitorOnlineUsers() ([]vo.OnlineUserVo, error) {
	onlineUsers, err := Hysteria2Online()
	if err != nil {
		return nil, err
	}
	if len(onlineUsers) == 0 {
		return []vo.OnlineUserVo{}, nil
	}
	usernames := make([]string, 0, len(onlineUsers))
	for u := range onlineUsers {
		usernames = append(usernames, u)
	}
	accounts, err := dao.ListAccountByUsernames(usernames)
	if err != nil {
		return nil, err
	}
	trafficMap := make(map[string]*entity.Account, len(accounts))
	for i := range accounts {
		trafficMap[*accounts[i].Username] = &accounts[i]
	}
	result := make([]vo.OnlineUserVo, 0, len(onlineUsers))
	for u, deviceCount := range onlineUsers {
		devices := deviceCount
		var download, upload int64
		if acc, ok := trafficMap[u]; ok {
			download = acc.Download
			upload = acc.Upload
		}
		result = append(result, vo.OnlineUserVo{
			Username:    u,
			DeviceCount: devices,
			Download:    download,
			Upload:      upload,
		})
	}
	return result, nil
}
