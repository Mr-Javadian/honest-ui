package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/Mr-Javadian/honest-ui/model/constant"
	"github.com/Mr-Javadian/honest-ui/model/vo"
	"github.com/Mr-Javadian/honest-ui/service"
	"github.com/Mr-Javadian/honest-ui/util"
)

func AdminHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		myClaims, err := service.ParseToken(service.GetToken(c))
		if err != nil {
			vo.Fail(err.Error(), c)
			c.Abort()
			return
		}
		if !util.ArrContain(myClaims.AccountBo.Roles, "admin") {
			vo.Fail(constant.ForbiddenError, c)
			c.Abort()
			return
		}
		c.Next()
	}
}
