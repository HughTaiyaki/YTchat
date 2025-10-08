package routes

import (
	"net/http"
	"ytchat/controllers"
	"ytchat/logger"

	"github.com/gin-gonic/gin"
)

func SetupRouter(mode string) *gin.Engine {
	if mode == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.New()
	r.Use(logger.GinLogger(), logger.GinRecovery(true))

	// 静态文件服务
	r.Static("/static", "./static")
	r.LoadHTMLGlob("templates/*")

	// 主页
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{})
	})

	// API路由组
	api := r.Group("/api")
	{
		// 视频管理
		api.GET("/videos", controllers.GetVideos)
		api.POST("/videos", controllers.AddVideo)
		api.DELETE("/videos/:id", controllers.DeleteVideo)

		// 聊天功能
		api.POST("/chat", controllers.ChatHandler)
		api.GET("/chat/history", controllers.GetChatHistory)
	}

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"message": "YouTube Chat Service is running",
		})
	})

	// 404处理
	r.NoRoute(func(c *gin.Context) {
		c.JSON(http.StatusNotFound, gin.H{
			"code":    404,
			"message": "Not Found",
		})
	})

	return r
}
