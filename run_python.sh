#!/bin/bash

# YouTube Chat Python服务启动脚本

echo "🐍 启动Python AI服务..."

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，请先运行: make install"
    exit 1
fi

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source venv/bin/activate

# 检查依赖是否安装
echo "🔍 检查Python依赖..."
if ! python -c "import fastapi, uvicorn, httpx" 2>/dev/null; then
    echo "📦 安装Python依赖..."
    pip install -r requirements.txt
fi

# 启动Python服务
echo "🚀 启动Python AI服务..."
python python_service.py
