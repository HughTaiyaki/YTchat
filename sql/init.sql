-- YouTube Chat 数据库初始化脚本
-- 创建数据库和表结构

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `ytchat` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `ytchat`;

-- 创建视频表
CREATE TABLE IF NOT EXISTS `videos` (
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
    KEY `idx_title` (`title`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='视频表';

-- 创建视频片段表
CREATE TABLE IF NOT EXISTS `video_segments` (
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
    CONSTRAINT `fk_video_segments_video_id` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='视频片段表';

-- 创建聊天消息表
CREATE TABLE IF NOT EXISTS `chat_messages` (
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
    CONSTRAINT `fk_chat_messages_video_id` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='聊天消息表';

-- 创建索引优化查询性能
CREATE INDEX `idx_videos_duration` ON `videos` (`duration`);
CREATE INDEX `idx_video_segments_time_range` ON `video_segments` (`video_id`, `start_time`, `end_time`);
CREATE INDEX `idx_chat_messages_time_range` ON `chat_messages` (`video_id`, `start_time`, `end_time`);

-- 插入示例数据（可选）
INSERT INTO `videos` (`youtube_id`, `title`, `description`, `thumbnail`, `duration`) VALUES
('Ylvr5hl6hYo', '示例视频1 - 技术教程', '这是一个关于编程技术的教程视频，包含了详细的操作步骤和代码示例。', 'https://img.youtube.com/vi/Ylvr5hl6hYo/maxresdefault.jpg', 1800),
('dQw4w9WgXcQ', '示例视频2 - 音乐视频', '这是一个音乐视频，包含了优美的旋律和精彩的视觉效果。', 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', 212);

-- 插入示例视频片段
INSERT INTO `video_segments` (`video_id`, `start_time`, `end_time`, `content`, `summary`) VALUES
(1, 0, 300, '视频开头部分，介绍主题和背景', '这部分主要介绍了视频的主题和背景信息，为后续内容做铺垫。'),
(1, 300, 600, '核心内容讲解，详细步骤演示', '这是视频的核心部分，包含了详细的操作步骤和代码示例。'),
(1, 600, 900, '实践操作，动手练习', '这部分提供了实践操作的机会，让观众能够动手练习所学内容。'),
(1, 900, 1200, '常见问题解答，注意事项', '解答了学习过程中可能遇到的常见问题，并提醒了重要的注意事项。'),
(1, 1200, 1500, '总结回顾，知识点梳理', '对整节课的内容进行了总结回顾，帮助观众梳理知识点。'),
(1, 1500, 1800, '作业布置，下期预告', '布置了课后作业，并预告了下期视频的内容。');

-- 插入示例聊天记录
INSERT INTO `chat_messages` (`question`, `answer`, `video_id`, `start_time`, `end_time`) VALUES
('这个视频主要讲了什么？', '这个视频主要介绍了编程技术的基础知识，包括理论讲解和实践操作。视频分为6个主要部分：开头介绍、核心内容、实践操作、问题解答、总结回顾和作业布置。', 1, 0, 300),
('视频中有哪些实践操作？', '视频在第三部分（10-15分钟）包含了详细的实践操作环节，观众可以跟着视频进行动手练习，巩固所学知识。', 1, 600, 900);

-- 显示创建结果
SELECT 'Database and tables created successfully!' as message;
SELECT COUNT(*) as video_count FROM videos;
SELECT COUNT(*) as segment_count FROM video_segments;
SELECT COUNT(*) as message_count FROM chat_messages;
