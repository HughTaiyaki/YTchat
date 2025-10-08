# YouTube 视频问答系统

一个基于Go + Python的智能视频问答系统，支持YouTube视频内容分析和智能问答。

## 功能特性

- 🎥 **视频库管理**: 手动添加YouTube视频，构建专属视频库
- 🤖 **智能问答**: 基于视频内容的AI问答，支持多轮对话
- ⏰ **精确定位**: 提供相关视频片段的时间戳，点击即可跳转播放
- 🔍 **内容分析**: 自动分析视频内容，生成结构化片段
- 💬 **实时聊天**: 现代化的聊天界面，支持实时交互
- 🔥 **热启动**: 支持代码热重载，提升开发效率
- 📊 **日志系统**: 完整的日志记录和监控
- ⚙️ **配置管理**: 灵活的配置文件管理

## 技术栈

- **后端**: Go + Gin框架 + Air热启动
- **AI服务**: Python + FastAPI + 百度千帆API
- **数据库**: SQLite/MySQL + GORM
- **前端**: HTML + Bootstrap + JavaScript
- **日志**: Zap + Lumberjack
- **配置**: Viper
- **AI模型**: 百度千帆 ernie-3.5-8k-preview

## 项目结构

```
YTchat/
├── cmd/                 # 主程序入口
│   └── main.go         # 主程序
├── conf/               # 配置文件
│   └── config.json     # 应用配置
├── settings/           # 配置管理
│   └── settings.go     # 配置结构体
├── logger/             # 日志系统
│   └── logger.go       # 日志配置
├── dao/                # 数据访问层
│   ├── mysql.go        # MySQL连接
│   └── sqlite.go       # SQLite连接
├── models/             # 数据模型
│   └── models.go       # 数据模型定义
├── controllers/        # 控制器层
│   ├── video.go        # 视频控制器
│   └── chat.go         # 聊天控制器
├── routes/             # 路由层
│   └── routes.go       # 路由配置
├── pkg/                # 公共包
│   └── python_client/  # Python服务客户端
├── templates/          # 前端模板
│   └── index.html      # 主页面
├── static/             # 静态文件
├── logs/               # 日志文件
├── data/               # 数据文件
├── python_service.py   # Python AI服务
├── requirements.txt    # Python依赖
├── go.mod             # Go依赖
├── .air.conf          # Air热启动配置
├── Makefile           # 构建脚本
└── README.md          # 项目说明
```

## 快速开始

### 方法1: 使用Makefile (推荐)

```bash
# 安装依赖
make install

# 开发模式运行（热启动）
make dev

# 或者启动完整服务
make start
```

### 方法2: 手动启动

**1. 安装依赖:**
```bash
# 使用Makefile自动安装（推荐）
make install

# 或手动安装
# Go依赖
go mod tidy

# Python虚拟环境
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 安装Air热启动工具
go install github.com/cosmtrek/air@latest
```

**2. 配置环境:**
复制示例配置并填写你的密钥（真实配置不提交到Git）：
```bash
cp conf/config.example.json conf/config.json
# 编辑 conf/config.json，填入数据库与API密钥
```

**3. 启动服务:**
```bash
# 方法1: 使用启动脚本（推荐）
./start_new.sh

# 方法2: 分别启动
# 启动Python AI服务
./run_python.sh

# 启动Go Web服务（热启动模式）
air

# 方法3: 手动启动
source venv/bin/activate
python python_service.py &
air
```

### 4. 访问系统

打开浏览器访问: http://localhost:8080

## 使用说明

### 添加视频
1. 点击"添加视频"按钮
2. 输入YouTube视频链接
3. 系统自动获取视频信息并分析内容

### 智能问答
1. 在聊天界面输入问题
2. AI基于视频库内容回答问题
3. 如有相关视频片段，点击链接跳转播放

## API接口

### 视频管理
- `GET /api/videos` - 获取视频列表
- `POST /api/videos` - 添加视频
- `DELETE /api/videos/:id` - 删除视频

### 聊天功能
- `POST /api/chat` - 发送问题
- `GET /api/chat/history` - 获取聊天历史

## 开发说明

### 数据库模型
- `Video`: 视频信息
- `VideoSegment`: 视频片段
- `ChatMessage`: 聊天记录

### AI服务集成
系统使用百度千帆API进行内容分析和问答处理，支持:
- 视频内容分析
- 智能问答
- 片段定位

### 扩展功能
- 支持更多视频平台
- 用户系统
- 视频推荐
- 批量导入

## 注意事项

1. 确保Python服务在8000端口运行
2. 配置正确的百度千帆API密钥
3. 网络连接正常，能够访问YouTube
4. 建议使用Chrome或Firefox浏览器

## 许可证

MIT License
