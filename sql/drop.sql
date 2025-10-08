-- YouTube Chat 数据库删除脚本
-- 删除所有表和数据库（谨慎使用！）

USE `ytchat`;

-- 删除外键约束
ALTER TABLE `video_segments` DROP FOREIGN KEY `fk_video_segments_video_id`;
ALTER TABLE `chat_messages` DROP FOREIGN KEY `fk_chat_messages_video_id`;

-- 删除表
DROP TABLE IF EXISTS `chat_messages`;
DROP TABLE IF EXISTS `video_segments`;
DROP TABLE IF EXISTS `videos`;

-- 删除数据库（可选）
-- DROP DATABASE IF EXISTS `ytchat`;

SELECT 'Database dropped successfully!' as message;
