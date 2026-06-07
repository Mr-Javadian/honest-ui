package controller

import (
	"github.com/Mr-Javadian/honest-ui/model/vo"
	"github.com/Mr-Javadian/honest-ui/service"
	"github.com/gin-gonic/gin"
)

func MonitorSystem(c *gin.Context) {
	systemMonitorVo, err := service.MonitorSystem()
	if err != nil {
		vo.Fail(err.Error(), c)
		return
	}
	vo.Success(systemMonitorVo, c)
}

func MonitorHysteria2(c *gin.Context) {
	hysteria2MonitorVo, err := service.MonitorHysteria2()
	if err != nil {
		vo.Fail(err.Error(), c)
		return
	}
	vo.Success(hysteria2MonitorVo, c)
}

func MonitorDashboard(c *gin.Context) {
	dashboardVo, err := service.MonitorDashboard()
	if err != nil {
		vo.Fail(err.Error(), c)
		return
	}
	vo.Success(dashboardVo, c)
}

func MonitorOnlineUsers(c *gin.Context) {
	onlineUsers, err := service.MonitorOnlineUsers()
	if err != nil {
		vo.Fail(err.Error(), c)
		return
	}
	vo.Success(onlineUsers, c)
}

func MonitorNetwork(c *gin.Context) {
	networkInfo := service.MonitorNetwork()
	vo.Success(networkInfo, c)
}
