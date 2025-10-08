# 🚀 YouTube 视频问答系统 - 快速开始

## 📋 系统要求

- **Go**: 1.21+ 
- **Python**: 3.9+
- **浏览器**: Chrome/Firefox/Safari
- **网络**: 能够访问YouTube和百度千帆API

## ⚡ 一键启动

### 方法1: 使用启动脚本 (推荐)
```bash
# 1. 安装依赖
make install

# 2. 启动系统
./start_new.sh
```

### 方法2: 手动启动
```bash
# 1. 安装Python依赖
pip3 install -r requirements.txt

# 2. 安装Go依赖
go mod tidy

# 3. 启动Python服务 (终端1)
python3 python_service.py

# 4. 启动Go服务 (终端2)
go run .
```

## 🌐 访问系统

打开浏览器访问: **http://localhost:8080**

## 📝 使用指南

### 1. 添加视频
1. 点击"添加视频"按钮
2. 输入YouTube视频链接，例如：
   - `https://www.youtube.com/watch?v=Ylvr5hl6hYo`
   - `https://youtu.be/Ylvr5hl6hYo`
3. 系统自动获取视频信息并分析内容

### 2. 智能问答
1. 在聊天界面输入问题，例如：
   - "这个视频主要讲了什么？"
   - "视频中有哪些重要内容？"
   - "第10分钟讲了什么？"
2. AI会基于视频内容回答问题
3. 如有相关片段，点击链接跳转播放

### 3. 视频管理
- 查看视频库中的所有视频
- 删除不需要的视频
- 查看视频基本信息

## 🔧 配置说明

### API密钥配置
编辑 `.env` 文件（首次安装可运行 `make install` 自动创建并复制模板）：

```bash
# 百度千帆API密钥（必需）
QIANFAN_API_KEY=your_api_key_here

# YouTube API密钥（可选，用于获取更准确的视频信息）
YOUTUBE_API_KEY=your_youtube_api_key_here
```

### 百度千帆API配置
1. 访问 [百度智能云](https://cloud.baidu.com/)
2. 开通千帆大模型服务
3. 获取API密钥
4. 在代码中更新 `qianfan_headers` 中的Authorization

## 🧪 测试系统

运行测试脚本验证系统功能：
```bash
python3 test_system.py
```

## 📊 系统状态

### 服务端口
- **Go Web服务**: http://localhost:8080
- **Python AI服务**: http://localhost:8000

### 健康检查
```bash
# 检查Go服务
curl http://localhost:8080/

# 检查Python服务
curl http://localhost:8000/
```

## 🐛 常见问题

### 1. Python服务启动失败
```bash
# 检查Python版本
python3 --version

# 安装依赖
pip3 install -r requirements.txt
```

### 2. Go服务启动失败
```bash
# 检查Go版本
go version

# 安装依赖
go mod tidy
```

### 3. API调用失败
- 检查网络连接
- 验证API密钥配置
- 查看服务日志

### 4. 数据库问题
```bash
# 删除数据库重新创建
rm ytchat.db
go run .
```

## 📈 性能优化

### 生产环境部署
1. 使用 `GIN_MODE=release`
2. 配置反向代理 (Nginx)
3. 使用PostgreSQL替代SQLite
4. 配置Redis缓存

### Docker部署
```bash
# 使用Docker Compose
docker-compose up -d
```

## 🔄 更新系统

```bash
# 拉取最新代码
git pull

# 重新安装依赖
make install

# 重启服务
./start_new.sh
```

## 📞 技术支持

如遇问题，请检查：
1. 服务是否正常启动
2. 网络连接是否正常
3. API密钥是否正确配置
4. 查看错误日志

---

🎉 **恭喜！** 你已经成功搭建了YouTube视频问答系统！

现在可以开始添加视频并进行智能问答了！
