# YouTube Chat Makefile

.PHONY: help build run dev clean install test init-db drop-db

# 默认目标
help:
	@echo "YouTube Chat 项目管理命令:"
	@echo "  make install    - 安装依赖"
	@echo "  make fix-python - 修复Python依赖问题"
	@echo "  make init-db    - 初始化数据库"
	@echo "  make drop-db    - 删除数据库"
	@echo "  make build      - 编译项目"
	@echo "  make run        - 运行项目"
	@echo "  make dev        - 开发模式运行（热启动）"
	@echo "  make clean      - 清理临时文件"
	@echo "  make test       - 运行测试"

# 安装依赖
install:
	@echo "📦 安装Go依赖..."
	go mod tidy
	@echo "🐍 设置Python虚拟环境..."
	@if [ ! -d "venv" ]; then python3 -m venv venv; fi
	@source venv/bin/activate && pip install --upgrade pip
	@echo "🔧 安装Python依赖..."
	@source venv/bin/activate && pip install -r requirements.txt || ./fix_python_deps.sh
	@echo "📦 安装Air热启动工具..."
	go install github.com/cosmtrek/air@latest

# 修复Python依赖
fix-python:
	@echo "🔧 修复Python依赖..."
	./fix_python_deps.sh

# 编译项目
build:
	@echo "🔨 编译项目..."
	go build -o bin/ytchat ./cmd

# 运行项目
run: build
	@echo "🚀 运行项目..."
	./bin/ytchat

# 开发模式运行（热启动）
dev:
	@echo "🔥 开发模式运行（热启动）..."
	air

# 清理临时文件
clean:
	@echo "🧹 清理临时文件..."
	rm -rf tmp/
	rm -rf bin/
	rm -f *.log

# 运行测试
test:
	@echo "🧪 运行测试..."
	go test ./...

# 初始化数据库
init-db:
	@echo "📊 初始化数据库..."
	./init_db.sh

# 删除数据库
drop-db:
	@echo "🗑️ 删除数据库..."
	mysql -u root -p < sql/drop.sql

# 创建必要目录
setup:
	@echo "📁 创建必要目录..."
	mkdir -p logs data tmp bin sql

# 启动完整服务
start: setup init-db
	@echo "🚀 启动完整服务..."
	./start_new.sh
