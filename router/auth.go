package router

import (
	"github.com/gin-gonic/gin"
	"github.com/Mr-Javadian/honest-ui/controller"
)

func initAuthRouter(authApi *gin.RouterGroup) {
	auth := authApi.Group("/auth")
	{
		auth.POST("/login", controller.Login)
	}
}
