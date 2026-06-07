package router

import (
	"github.com/Mr-Javadian/honest-ui/controller"
	"github.com/gin-gonic/gin"
)

func initMonitorRouter(accountApi *gin.RouterGroup) {
	account := accountApi.Group("/monitor")
	{
		account.GET("/monitorSystem", controller.MonitorSystem)
		account.GET("/monitorHysteria2", controller.MonitorHysteria2)
		account.GET("/monitorDashboard", controller.MonitorDashboard)
		account.GET("/monitorOnlineUsers", controller.MonitorOnlineUsers)
	}
}
