package controllers

import (
	"net/http"
	"strconv"
	"strings"
	"ytchat/dao"
	"ytchat/models"
	"ytchat/pkg/python_client"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// GetVideos 获取视频列表
func GetVideos(c *gin.Context) {
	var videos []models.Video
	db := dao.GetDB()
	result := db.Preload("Segments").Find(&videos)

	if result.Error != nil {
		zap.L().Error("获取视频列表失败", zap.Error(result.Error))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "获取视频列表失败",
		})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Code:    200,
		Message: "获取成功",
		Data:    videos,
	})
}

// AddVideo 添加视频
func AddVideo(c *gin.Context) {
	var req models.AddVideoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		zap.L().Error("请求参数错误", zap.Error(err))
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Code:    400,
			Message: "请求参数错误: " + err.Error(),
		})
		return
	}

	// 提取YouTube视频ID
	videoID := extractYouTubeID(req.YouTubeURL)
	if videoID == "" {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Code:    400,
			Message: "无效的YouTube URL",
		})
		return
	}

	// 检查视频是否已存在
	db := dao.GetDB()
	var existingVideo models.Video
	result := db.Where("you_tube_id = ?", videoID).First(&existingVideo)
	if result.Error == nil {
		c.JSON(http.StatusConflict, models.APIResponse{
			Code:    409,
			Message: "视频已存在",
		})
		return
	}

	// 调用Python服务获取视频信息
	videoInfo, err := python_client.GetVideoInfoFromPython(videoID)
	if err != nil {
		zap.L().Error("获取视频信息失败", zap.Error(err))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "获取视频信息失败: " + err.Error(),
		})
		return
	}

	// 保存视频到数据库
	video := models.Video{
		YouTubeID:   videoID,
		Title:       videoInfo.Title,
		Description: videoInfo.Description,
		Thumbnail:   videoInfo.Thumbnail,
		Duration:    videoInfo.Duration,
	}

	result = db.Create(&video)
	if result.Error != nil {
		zap.L().Error("保存视频失败", zap.Error(result.Error))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "保存视频失败",
		})
		return
	}

	// 异步处理视频内容分析
	go python_client.ProcessVideoContent(video.ID, videoID)

	zap.L().Info("视频添加成功", zap.String("video_id", videoID), zap.String("title", videoInfo.Title))
	c.JSON(http.StatusOK, models.APIResponse{
		Code:    200,
		Message: "视频添加成功",
		Data:    video,
	})
}

// DeleteVideo 删除视频
func DeleteVideo(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{
			Code:    400,
			Message: "无效的视频ID",
		})
		return
	}

	db := dao.GetDB()
	result := db.Delete(&models.Video{}, id)
	if result.Error != nil {
		zap.L().Error("删除视频失败", zap.Error(result.Error))
		c.JSON(http.StatusInternalServerError, models.APIResponse{
			Code:    500,
			Message: "删除视频失败",
		})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, models.APIResponse{
			Code:    404,
			Message: "视频不存在",
		})
		return
	}

	zap.L().Info("视频删除成功", zap.Uint64("video_id", id))
	c.JSON(http.StatusOK, models.APIResponse{
		Code:    200,
		Message: "视频删除成功",
	})
}

// extractYouTubeID 从URL中提取YouTube视频ID
func extractYouTubeID(url string) string {
	// 处理各种YouTube URL格式
	if strings.Contains(url, "youtube.com/watch?v=") {
		parts := strings.Split(url, "v=")
		if len(parts) > 1 {
			id := strings.Split(parts[1], "&")[0]
			return id
		}
	} else if strings.Contains(url, "youtu.be/") {
		parts := strings.Split(url, "youtu.be/")
		if len(parts) > 1 {
			id := strings.Split(parts[1], "?")[0]
			return id
		}
	}
	return ""
}
