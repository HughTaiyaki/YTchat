#!/bin/bash

# YouTube 视频问答系统启动脚本 (新版本)

echo "🚀 启动 YouTube 视频问答系统 (新版本)..."

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，请先安装Python3"
    exit 1
fi

# 检查Go是否安装
if ! command -v go &> /dev/null; then
    echo "❌ Go 未安装，请先安装Go"
    exit 1
fi

# 检查Air是否安装
if ! command -v air &> /dev/null; then
    echo "📦 安装Air热启动工具..."
    go install github.com/cosmtrek/air@latest
fi

# 设置Python虚拟环境
echo "🐍 设置Python虚拟环境..."
if [ ! -d "venv" ]; then
    echo "📦 创建虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source venv/bin/activate

# 安装Python依赖
echo "📦 安装Python依赖..."
pip install -r requirements.txt

# 安装Go依赖
echo "📦 安装Go依赖..."
go mod tidy

# 创建必要的目录
mkdir -p logs data tmp

# 启动Python服务（后台运行）
echo "🐍 启动Python AI服务..."
source venv/bin/activate && python python_service.py &
PYTHON_PID=$!

# 等待Python服务启动
echo "⏳ 等待Python服务启动..."
sleep 3

# 启动Go服务（使用Air热启动）
echo "🚀 启动Go Web服务（热启动模式）..."
air

# 清理函数
cleanup() {
    echo "🛑 正在停止服务..."
    kill $PYTHON_PID 2>/dev/null
    exit 0
}

# 捕获中断信号
trap cleanup SIGINT SIGTERM

echo "✅ 系统启动完成！"
echo "🌐 访问地址: http://localhost:8080"
echo "按 Ctrl+C 停止服务"
