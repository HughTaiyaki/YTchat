package controllers

import (
	"net/http"
	"ytchat/dao"
	"ytchat/models"
	"ytchat/pkg/python_client"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// ChatHandler 处理聊天请求
func ChatHandler(c *gin.Context) {
	var req models.ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		zap.L().Error("请求参数错误", zap.Error(err))
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Code:    400,
			Message: "请求参数错误: " + err.Error(),
		})
		return
	}

	// 调用Python服务处理问答
	response, err := python_client.ProcessChatWithPython(req.Question)
	if err != nil {
		zap.L().Error("处理问答失败", zap.Error(err))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "处理问答失败: " + err.Error(),
		})
		return
	}

	// 保存聊天记录
	db := dao.GetDB()

	// 转换VideoID类型
	var videoID *uint
	if response.VideoID != nil {
		videoIDValue := uint(*response.VideoID)
		videoID = &videoIDValue
	}

	chatMessage := models.ChatMessage{
		Question:  req.Question,
		Answer:    response.Answer,
		VideoID:   videoID,
		StartTime: response.StartTime,
		EndTime:   response.EndTime,
	}

	if err := db.Create(&chatMessage).Error; err != nil {
		zap.L().Error("保存聊天记录失败", zap.Error(err))
	}

	// 如果有相关视频，加载视频信息
	if response.VideoID != nil {
		var video models.Video
		if err := db.First(&video, *response.VideoID).Error; err == nil {
			response.Video = &video
		}
	}

	zap.L().Info("聊天处理成功",
		zap.String("question", req.Question),
		zap.String("answer", response.Answer[:min(50, len(response.Answer))]),
	)

	c.JSON(http.StatusOK, models.APIResponse{
		Code:    200,
		Message: "处理成功",
		Data:    response,
	})
}

// GetChatHistory 获取聊天历史
func GetChatHistory(c *gin.Context) {
	var messages []models.ChatMessage
	db := dao.GetDB()
	result := db.Preload("Video").Order("created_at DESC").Limit(50).Find(&messages)

	if result.Error != nil {
		zap.L().Error("获取聊天历史失败", zap.Error(result.Error))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "获取聊天历史失败",
		})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Code:    200,
		Message: "获取成功",
		Data:    messages,
	})
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
