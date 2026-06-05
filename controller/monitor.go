package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/Mr-Javadian/honest-ui/model/vo"
	"github.com/Mr-Javadian/honest-ui/service"
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
