-- YouTube Chat 数据库表结构定义
-- 仅包含表结构，不包含数据

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `ytchat` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `ytchat`;

-- 视频表
CREATE TABLE `videos` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '视频ID',
    `youtube_id` varchar(50) NOT NULL COMMENT 'YouTube视频ID',
    `title` varchar(500) NOT NULL DEFAULT '' COMMENT '视频标题',
    `description` text COMMENT '视频描述',
    `thumbnail` varchar(500) NOT NULL DEFAULT '' COMMENT '缩略图URL',
    `duration` int(11) NOT NULL DEFAULT '0' COMMENT '视频时长(秒)',
    `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_youtube_id` (`youtube_id`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_title` (`title`(191)),
    KEY `idx_duration` (`duration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='视频表';

-- 视频片段表
CREATE TABLE `video_segments` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '片段ID',
    `video_id` bigint(20) unsigned NOT NULL COMMENT '视频ID',
    `start_time` int(11) NOT NULL DEFAULT '0' COMMENT '开始时间(秒)',
    `end_time` int(11) NOT NULL DEFAULT '0' COMMENT '结束时间(秒)',
    `content` text COMMENT '片段内容',
    `summary` text COMMENT '片段摘要',
    `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_video_id` (`video_id`),
    KEY `idx_start_time` (`start_time`),
    KEY `idx_end_time` (`end_time`),
    KEY `idx_time_range` (`video_id`, `start_time`, `end_time`),
    CONSTRAINT `fk_video_segments_video_id` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='视频片段表';

-- 聊天消息表
CREATE TABLE `chat_messages` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '消息ID',
    `question` text NOT NULL COMMENT '用户问题',
    `answer` text NOT NULL COMMENT 'AI回答',
    `video_id` bigint(20) unsigned DEFAULT NULL COMMENT '相关视频ID',
    `start_time` int(11) DEFAULT NULL COMMENT '相关开始时间(秒)',
    `end_time` int(11) DEFAULT NULL COMMENT '相关结束时间(秒)',
    `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_video_id` (`video_id`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_question` (`question`(191)),
    KEY `idx_time_range` (`video_id`, `start_time`, `end_time`),
    CONSTRAINT `fk_chat_messages_video_id` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天消息表';
