package dao

import (
	"fmt"
	"ytchat/models"
	"ytchat/settings"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var db *gorm.DB

func Init(cfg *settings.MySQLConfig) (err error) {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		cfg.User, cfg.Password, cfg.Host, cfg.Port, cfg.DbName,
	)
	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		return
	}

	sqlDB, err := db.DB()
	if err != nil {
		return
	}

	sqlDB.SetMaxOpenConns(cfg.MaxOpenConns)
	sqlDB.SetMaxIdleConns(cfg.MaxIdleConns)

	// 自动迁移
	err = db.AutoMigrate(&models.Video{}, &models.VideoSegment{}, &models.ChatMessage{})
	if err != nil {
		return
	}

	return
}

func GetDB() *gorm.DB {
	return db
}

func Close() {
	sqlDB, err := db.DB()
	if err != nil {
		return
	}
	sqlDB.Close()
}
