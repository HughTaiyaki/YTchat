FROM python:3.9-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 安装Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz \
    && rm go1.21.0.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt go.mod go.sum ./

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 下载Go依赖
RUN go mod download

# 复制源代码
COPY . .

# 创建数据和日志目录
RUN mkdir -p /app/data /app/logs

# 构建Go应用（可选，用于生产环境）
# RUN go build -o ytchat cmd/main.go

# 暴露端口
EXPOSE 8000 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 默认启动命令
CMD ["python", "python_service.py"]
