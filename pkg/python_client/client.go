package python_client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
	"ytchat/dao"
	"ytchat/models"
	"ytchat/settings"

	"go.uber.org/zap"
)

// VideoInfoResponse Python服务返回的视频信息
type VideoInfoResponse struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Thumbnail   string `json:"thumbnail"`
	Duration    int    `json:"duration"`
}

// ChatRequest 发送给Python服务的聊天请求
type ChatRequest struct {
	Question string `json:"question"`
}

// ChatResponse Python服务返回的聊天响应
type ChatResponse struct {
	Answer    string        `json:"answer"`
	VideoID   *uint         `json:"video_id,omitempty"`
	YouTubeID *string       `json:"youtube_id,omitempty"`
	StartTime *int          `json:"start_time,omitempty"`
	EndTime   *int          `json:"end_time,omitempty"`
	Video     *models.Video `json:"video,omitempty"`
}

// GetVideoInfoFromPython 从Python服务获取视频信息
func GetVideoInfoFromPython(videoID string) (*VideoInfoResponse, error) {
	client := &http.Client{Timeout: 30 * time.Second}

	url := fmt.Sprintf("%s/video/%s", settings.Conf.PythonServiceConfig.URL, videoID)
	resp, err := client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("请求Python服务失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("Python服务返回错误: %s", string(body))
	}

	var videoInfo VideoInfoResponse
	if err := json.NewDecoder(resp.Body).Decode(&videoInfo); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	return &videoInfo, nil
}

// ProcessChatWithPython 使用Python服务处理聊天
func ProcessChatWithPython(question string) (*ChatResponse, error) {
	client := &http.Client{Timeout: time.Duration(settings.Conf.PythonServiceConfig.Timeout) * time.Second}

	reqBody := ChatRequest{Question: question}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %v", err)
	}

	resp, err := client.Post(settings.Conf.PythonServiceConfig.URL+"/chat", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("请求Python服务失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("Python服务返回错误: %s", string(body))
	}

	var chatResp ChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&chatResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	// 转换VideoID类型从int到uint
	if chatResp.VideoID != nil {
		videoIDValue := uint(*chatResp.VideoID)
		chatResp.VideoID = &videoIDValue
	}

	return &chatResp, nil
}

// ProcessVideoContent 异步处理视频内容分析
func ProcessVideoContent(videoID uint, youtubeID string) {
	client := &http.Client{Timeout: 300 * time.Second}

	url := fmt.Sprintf("%s/video/%s/analyze", settings.Conf.PythonServiceConfig.URL, youtubeID)
	resp, err := client.Post(url, "application/json", nil)
	if err != nil {
		zap.L().Error("分析视频内容失败", zap.Error(err))
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		zap.L().Error("分析视频内容失败", zap.String("error", string(body)))
		return
	}

	var result struct {
		Segments []struct {
			StartTime int    `json:"start_time"`
			EndTime   int    `json:"end_time"`
			Content   string `json:"content"`
			Summary   string `json:"summary"`
		} `json:"segments"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		zap.L().Error("解析分析结果失败", zap.Error(err))
		return
	}

	// 保存片段到数据库
	db := dao.GetDB()
	for _, segment := range result.Segments {
		videoSegment := models.VideoSegment{
			VideoID:   videoID,
			StartTime: segment.StartTime,
			EndTime:   segment.EndTime,
			Content:   segment.Content,
			Summary:   segment.Summary,
		}
		if err := db.Create(&videoSegment).Error; err != nil {
			zap.L().Error("保存视频片段失败", zap.Error(err))
		}
	}

	zap.L().Info("视频内容分析完成",
		zap.String("youtube_id", youtubeID),
		zap.Int("segments_count", len(result.Segments)),
	)
}
