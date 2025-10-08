package dao

import (
	"os"
	"path/filepath"
	"ytchat/models"
	"ytchat/settings"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var sqliteDB *gorm.DB

func InitSQLite(cfg *settings.SQLiteConfig) (err error) {
	// 确保数据目录存在
	dir := filepath.Dir(cfg.Path)
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		os.MkdirAll(dir, 0755)
	}

	sqliteDB, err = gorm.Open(sqlite.Open(cfg.Path), &gorm.Config{})
	if err != nil {
		return
	}

	// 自动迁移
	err = sqliteDB.AutoMigrate(&models.Video{}, &models.VideoSegment{}, &models.ChatMessage{})
	if err != nil {
		return
	}

	return
}

func GetSQLiteDB() *gorm.DB {
	return sqliteDB
}

func CloseSQLite() {
	sqlDB, err := sqliteDB.DB()
	if err != nil {
		return
	}
	sqlDB.Close()
}
