#!/bin/bash

# Python依赖修复脚本

echo "🔧 修复Python依赖问题..."

# 检查Python版本
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "🐍 Python版本: $PYTHON_VERSION"

# 创建虚拟环境
echo "📦 创建虚拟环境..."
if [ -d "venv" ]; then
    echo "🗑️ 删除现有虚拟环境..."
    rm -rf venv
fi

python3 -m venv venv

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source venv/bin/activate

# 升级pip和setuptools
echo "⬆️ 升级pip和setuptools..."
pip install --upgrade pip setuptools wheel

# 根据Python版本安装兼容的依赖
if [[ "$PYTHON_VERSION" == "3.13" ]]; then
    echo "🔧 检测到Python 3.13，使用兼容版本..."
    
    # 先安装基础依赖
    pip install wheel cython
    
    # 安装兼容版本的pydantic
    pip install "pydantic>=2.0,<2.5"
    
    # 安装其他依赖
    pip install fastapi==0.104.1
    pip install uvicorn==0.24.0
    pip install httpx==0.25.2
    pip install python-multipart==0.0.6
    
elif [[ "$PYTHON_VERSION" == "3.12" ]]; then
    echo "🔧 检测到Python 3.12，使用标准版本..."
    pip install -r requirements.txt
    
elif [[ "$PYTHON_VERSION" == "3.11" ]]; then
    echo "🔧 检测到Python 3.11，使用标准版本..."
    pip install -r requirements.txt
    
else
    echo "⚠️ 检测到Python $PYTHON_VERSION，尝试安装兼容版本..."
    
    # 尝试安装较旧但稳定的版本
    pip install wheel cython
    pip install "pydantic>=2.0,<2.5"
    pip install fastapi==0.104.1
    pip install uvicorn==0.24.0
    pip install httpx==0.25.2
    pip install python-multipart==0.0.6
fi

# 验证安装
echo "✅ 验证安装..."
if python -c "import fastapi, uvicorn, httpx, pydantic" 2>/dev/null; then
    echo "🎉 依赖安装成功！"
    
    # 显示已安装的包
    echo "📦 已安装的包:"
    pip list | grep -E "(fastapi|uvicorn|httpx|pydantic)"
    
else
    echo "❌ 依赖安装失败，尝试备用方案..."
    
    # 备用方案：使用更旧的稳定版本
    echo "🔄 尝试安装稳定版本..."
    pip install --upgrade pip
    pip install wheel
    pip install "pydantic==2.0.7"
    pip install "fastapi==0.100.0"
    pip install "uvicorn==0.23.0"
    pip install "httpx==0.24.0"
    pip install "python-multipart==0.0.6"
    
    # 再次验证
    if python -c "import fastapi, uvicorn, httpx, pydantic" 2>/dev/null; then
        echo "✅ 备用方案安装成功！"
    else
        echo "❌ 所有方案都失败了，请检查Python版本或网络连接"
        exit 1
    fi
fi

echo ""
echo "🚀 现在可以启动服务了:"
echo "   ./run_python.sh"
echo "   或"
echo "   ./start_new.sh"
