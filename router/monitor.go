package router

import (
	"github.com/gin-gonic/gin"
	"github.com/Mr-Javadian/honest-ui/controller"
)

func initMonitorRouter(accountApi *gin.RouterGroup) {
	account := accountApi.Group("/monitor")
	{
		account.GET("/monitorSystem", controller.MonitorSystem)
		account.GET("/monitorHysteria2", controller.MonitorHysteria2)
	}
}
