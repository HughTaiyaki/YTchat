#!/bin/bash

# YouTube Chat 数据库初始化脚本

echo "🚀 初始化 YouTube Chat 数据库..."

# 检查MySQL是否安装
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL 未安装，请先安装MySQL"
    exit 1
fi

# 读取配置文件中的数据库信息
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASS="darknessyifu78g"
DB_NAME="ytchat"

echo "📊 数据库配置:"
echo "  主机: $DB_HOST"
echo "  端口: $DB_PORT"
echo "  用户: $DB_USER"
echo "  数据库: $DB_NAME"

# 检查数据库连接
echo "🔍 检查数据库连接..."
if ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; then
    echo "❌ 无法连接到MySQL数据库，请检查配置"
    echo "   请确保MySQL服务正在运行"
    echo "   请检查用户名和密码是否正确"
    exit 1
fi

echo "✅ 数据库连接成功"

# 创建数据库和表
echo "📝 创建数据库和表结构..."
if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" < sql/init.sql; then
    echo "✅ 数据库初始化成功"
else
    echo "❌ 数据库初始化失败"
    exit 1
fi

# 显示数据库状态
echo "📊 数据库状态:"
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "
USE $DB_NAME;
SELECT 'Videos' as table_name, COUNT(*) as count FROM videos
UNION ALL
SELECT 'Video Segments', COUNT(*) FROM video_segments
UNION ALL
SELECT 'Chat Messages', COUNT(*) FROM chat_messages;
"

echo ""
echo "🎉 数据库初始化完成！"
echo "🌐 现在可以启动应用了:"
echo "   make dev"
echo "   或"
echo "   ./start_new.sh"
