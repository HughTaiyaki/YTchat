# YTchat 部署指南

## 🚀 快速部署（Docker方式）

### 前置要求
- Docker 20.10+
- Docker Compose 2.0+
- 服务器内存 ≥ 2GB
- 磁盘空间 ≥ 10GB

### 1. 环境准备
```bash
# 安装Docker（Ubuntu/Debian）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. 项目部署
```bash
# 克隆项目
git clone <your-repository-url> /opt/ytchat
cd /opt/ytchat

# 配置环境变量
cp config.env .env
nano .env  # 编辑配置文件
```

### 3. 生产环境配置
编辑 `.env` 文件：
```env
# 服务器配置
PORT=8080
GIN_MODE=release

# Python服务配置
PYTHON_SERVICE_URL=http://python-service:8000

# 数据库配置
DB_PATH=/app/data/ytchat.db

# YouTube API配置
YOUTUBE_API_KEY=your_actual_api_key_here
```

### 4. 启动服务
```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 检查服务状态
docker-compose ps
```

### 5. 反向代理配置（Nginx）
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🌐 云服务部署方案

### 方案1: 阿里云ECS
**推荐配置：**
- CPU: 2核
- 内存: 4GB
- 磁盘: 40GB SSD
- 带宽: 5Mbps
- 预估费用: ¥200-300/月

**部署步骤：**
1. 购买ECS实例（选择Ubuntu 20.04）
2. 配置安全组（开放80, 443, 8080端口）
3. 安装Docker和Docker Compose
4. 部署项目
5. 配置域名和SSL证书

### 方案2: 腾讯云轻量服务器
**推荐配置：**
- 2核4GB内存
- 60GB SSD
- 8Mbps带宽
- 预估费用: ¥24-88/月

### 方案3: Railway（推荐新手）
**优势：**
- 支持GitHub自动部署
- 内置数据库
- 免费额度：$5/月
- 零配置部署

**部署步骤：**
1. 连接GitHub仓库
2. 添加环境变量
3. 自动构建部署

### 方案4: DigitalOcean Droplet
**推荐配置：**
- Basic Droplet: $12/月
- 2GB内存, 1核CPU
- 50GB SSD, 2TB流量

## 🔒 安全配置

### 1. 防火墙设置
```bash
# Ubuntu UFW
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. SSL证书（Let's Encrypt）
```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com
```

### 3. 环境变量安全
- 不要在代码中硬编码API密钥
- 使用环境变量或密钥管理服务
- 定期轮换API密钥

## 📊 监控和维护

### 1. 日志管理
```bash
# 查看应用日志
docker-compose logs -f --tail=100

# 设置日志轮转
# 在docker-compose.yml中添加：
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 2. 备份策略
```bash
# 数据库备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker cp ytchat_go-service_1:/app/data/ytchat.db ./backup/ytchat_$DATE.db
```

### 3. 更新部署
```bash
# 拉取最新代码
git pull origin main

# 重新构建并部署
docker-compose down
docker-compose up -d --build
```

## 🚨 故障排除

### 常见问题：
1. **端口被占用**：检查防火墙和端口配置
2. **内存不足**：升级服务器配置或优化应用
3. **API密钥失效**：检查YouTube API配置
4. **数据库连接失败**：检查数据库文件权限

### 性能优化：
- 启用Gzip压缩
- 配置CDN加速静态资源
- 数据库索引优化
- 启用HTTP/2

## 💰 成本估算

| 方案 | 月费用 | 适用场景 |
|------|--------|----------|
| Railway | $0-20 | 个人项目/测试 |
| 腾讯云轻量 | ¥24-88 | 小型项目 |
| 阿里云ECS | ¥200-300 | 中型项目 |
| AWS/Azure | $30-100 | 企业级项目 |

选择建议：
- **个人学习**：Railway或腾讯云轻量
- **小型项目**：阿里云/腾讯云ECS
- **商业项目**：AWS/Azure with CDN