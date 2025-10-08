# 📊 YouTube Chat 数据库脚本

这个目录包含了YouTube视频问答系统的所有数据库相关脚本。

## 📁 文件说明

### 1. `init.sql` - 完整初始化脚本
- 创建数据库和所有表
- 包含示例数据
- 适合首次部署使用

### 2. `schema.sql` - 纯表结构脚本
- 仅包含表结构定义
- 不包含示例数据
- 适合生产环境使用

### 3. `sample_data.sql` - 示例数据脚本
- 仅包含示例数据
- 用于测试和演示
- 需要先执行schema.sql

### 4. `drop.sql` - 删除脚本
- 删除所有表和数据库
- 谨慎使用！
- 用于重置数据库

## 🚀 使用方法

### 方法1: 完整初始化（推荐）
```bash
# 连接到MySQL
mysql -u root -p

# 执行完整初始化脚本
source /path/to/YTchat/sql/init.sql
```

### 方法2: 分步执行
```bash
# 1. 创建表结构
mysql -u root -p < sql/schema.sql

# 2. 插入示例数据（可选）
mysql -u root -p < sql/sample_data.sql
```

### 方法3: 使用命令行
```bash
# 创建数据库和表
mysql -u root -p -e "source sql/init.sql"

# 或者指定数据库
mysql -u root -p ytchat < sql/init.sql
```

## 📋 数据库结构

### 表关系图
```
videos (视频表)
├── id (主键)
├── youtube_id (唯一)
├── title
├── description
├── thumbnail
├── duration
└── created_at, updated_at

video_segments (视频片段表)
├── id (主键)
├── video_id (外键 -> videos.id)
├── start_time
├── end_time
├── content
├── summary
└── created_at, updated_at

chat_messages (聊天消息表)
├── id (主键)
├── question
├── answer
├── video_id (外键 -> videos.id, 可空)
├── start_time (可空)
├── end_time (可空)
└── created_at
```

### 索引说明
- `videos.youtube_id`: 唯一索引，确保视频ID不重复
- `video_segments.video_id`: 外键索引，优化关联查询
- `chat_messages.created_at`: 时间索引，优化按时间排序
- `video_segments.time_range`: 复合索引，优化时间范围查询

## 🔧 配置说明

### 数据库连接配置
在 `conf/config.json` 中配置数据库连接：

```json
{
  "mysql": {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "your_password",
    "dbname": "ytchat",
    "max_open_conns": 200,
    "max_idle_conns": 50
  }
}
```

### 字符集说明
- 数据库字符集: `utf8mb4`
- 排序规则: `utf8mb4_unicode_ci`
- 支持完整的Unicode字符，包括emoji

## 📊 示例数据

### 视频数据
- 4个示例视频
- 包含Go、Python、React、Docker等主题
- 总时长超过6小时

### 片段数据
- 每个视频包含多个时间片段
- 片段内容详细描述
- 便于AI问答定位

### 聊天记录
- 8条示例对话
- 涵盖技术问题和回答
- 包含视频片段引用

## ⚠️ 注意事项

### 1. 数据安全
- 执行删除脚本前请备份数据
- 生产环境谨慎使用示例数据
- 定期备份重要数据

### 2. 性能优化
- 大数据量时考虑分表策略
- 定期清理过期聊天记录
- 监控数据库性能指标

### 3. 权限管理
- 确保数据库用户有足够权限
- 生产环境使用专用数据库用户
- 限制数据库访问IP

## 🛠️ 维护脚本

### 数据清理
```sql
-- 清理30天前的聊天记录
DELETE FROM chat_messages 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- 清理无关联的片段
DELETE FROM video_segments 
WHERE video_id NOT IN (SELECT id FROM videos);
```

### 性能监控
```sql
-- 查看表大小
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'ytchat'
ORDER BY (data_length + index_length) DESC;

-- 查看索引使用情况
SHOW INDEX FROM videos;
SHOW INDEX FROM video_segments;
SHOW INDEX FROM chat_messages;
```

## 🔄 版本更新

### 添加新字段
```sql
-- 为视频表添加新字段
ALTER TABLE videos 
ADD COLUMN view_count INT DEFAULT 0 COMMENT '观看次数',
ADD COLUMN like_count INT DEFAULT 0 COMMENT '点赞次数';
```

### 修改字段类型
```sql
-- 修改字段类型
ALTER TABLE videos 
MODIFY COLUMN title VARCHAR(1000) NOT NULL DEFAULT '';
```

---

📝 **提示**: 建议在开发环境先测试这些脚本，确认无误后再在生产环境使用。
