package models

import (
	"time"
)

// Video 视频模型
type Video struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	YouTubeID   string    `json:"youtube_id" gorm:"column:you_tube_id;uniqueIndex;type:varchar(50);not null"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Thumbnail   string    `json:"thumbnail"`
	Duration    int       `json:"duration"` // 秒
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联
	Segments []VideoSegment `json:"segments" gorm:"foreignKey:VideoID"`
}

// VideoSegment 视频片段模型
type VideoSegment struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	VideoID   uint      `json:"video_id"`
	StartTime int       `json:"start_time"` // 开始时间（秒）
	EndTime   int       `json:"end_time"`   // 结束时间（秒）
	Content   string    `json:"content"`    // 片段内容
	Summary   string    `json:"summary"`    // 片段摘要
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联
	Video Video `json:"video" gorm:"foreignKey:VideoID"`
}

// ChatMessage 聊天消息模型
type ChatMessage struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Question  string    `json:"question"`
	Answer    string    `json:"answer"`
	VideoID   *uint     `json:"video_id,omitempty"`
	StartTime *int      `json:"start_time,omitempty"`
	EndTime   *int      `json:"end_time,omitempty"`
	CreatedAt time.Time `json:"created_at"`

	// 关联
	Video *Video `json:"video,omitempty" gorm:"foreignKey:VideoID"`
}

// APIResponse 统一API响应格式
type APIResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// ChatRequest 聊天请求
type ChatRequest struct {
	Question string `json:"question" binding:"required"`
}

// ChatResponse 聊天响应
type ChatResponse struct {
	Answer    string `json:"answer"`
	VideoID   *uint  `json:"video_id,omitempty"`
	StartTime *int   `json:"start_time,omitempty"`
	EndTime   *int   `json:"end_time,omitempty"`
	Video     *Video `json:"video,omitempty"`
}

// AddVideoRequest 添加视频请求
type AddVideoRequest struct {
	YouTubeURL string `json:"youtube_url" binding:"required"`
}
