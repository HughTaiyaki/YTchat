# 🐍 Python环境设置指南

## 问题说明

在macOS上，系统Python环境被外部管理（Homebrew），不允许直接安装包，会出现以下错误：

```
error: externally-managed-environment
× This environment is externally managed
```

## 🚀 解决方案

### 方法1: 使用虚拟环境（推荐）

我们已经在项目中集成了虚拟环境支持，直接使用即可：

```bash
# 自动设置Python环境
make install

# 启动服务
./start_new.sh
```

### 方法2: 手动设置虚拟环境

```bash
# 1. 创建虚拟环境
python3 -m venv venv

# 2. 激活虚拟环境
source venv/bin/activate

# 3. 升级pip
pip install --upgrade pip

# 4. 安装依赖
pip install -r requirements.txt

# 5. 启动Python服务
python python_service.py
```

### 方法3: 使用pipx（可选）

```bash
# 安装pipx
brew install pipx

# 使用pipx安装应用
pipx install fastapi uvicorn httpx
```

## 📁 项目结构

```
YTchat/
├── venv/                 # Python虚拟环境（自动创建）
├── requirements.txt      # Python依赖列表
├── python_service.py     # Python AI服务
├── run_python.sh        # Python服务启动脚本
└── start_new.sh         # 完整服务启动脚本
```

## 🔧 虚拟环境管理

### 激活虚拟环境
```bash
source venv/bin/activate
```

### 退出虚拟环境
```bash
deactivate
```

### 检查虚拟环境状态
```bash
# 查看Python路径
which python

# 查看已安装的包
pip list
```

### 重新创建虚拟环境
```bash
# 删除现有环境
rm -rf venv

# 重新创建
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 🚀 启动服务

### 完整启动（推荐）
```bash
./start_new.sh
```

### 分别启动
```bash
# 终端1: 启动Python服务
./run_python.sh

# 终端2: 启动Go服务
air
```

### 使用Makefile
```bash
# 安装依赖
make install

# 开发模式
make dev

# 完整启动
make start
```

## 🔍 故障排除

### 1. 虚拟环境激活失败
```bash
# 检查Python版本
python3 --version

# 重新创建虚拟环境
rm -rf venv
python3 -m venv venv
```

### 2. 依赖安装失败
```bash
# 升级pip
source venv/bin/activate
pip install --upgrade pip

# 使用国内镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

### 3. 端口被占用
```bash
# 检查端口占用
lsof -i :8000
lsof -i :8080

# 杀死进程
kill -9 <PID>
```

### 4. 权限问题
```bash
# 给脚本添加执行权限
chmod +x *.sh

# 检查文件权限
ls -la *.sh
```

## 📊 环境要求

### Python版本
- Python 3.9+
- 推荐使用Python 3.11

### 系统要求
- macOS 10.15+
- 至少2GB可用内存
- 至少1GB可用磁盘空间

### 依赖包
```
fastapi==0.104.1
uvicorn==0.24.0
httpx==0.25.2
pydantic==2.5.0
python-multipart==0.0.6
```

## 💡 最佳实践

### 1. 环境隔离
- 始终使用虚拟环境
- 不要污染系统Python环境
- 定期清理不需要的包

### 2. 依赖管理
- 使用requirements.txt管理依赖
- 定期更新依赖版本
- 记录依赖变更

### 3. 开发流程
```bash
# 1. 激活环境
source venv/bin/activate

# 2. 开发代码
# ... 编写代码 ...

# 3. 测试功能
python python_service.py

# 4. 退出环境
deactivate
```

## 🔄 更新依赖

### 更新单个包
```bash
source venv/bin/activate
pip install --upgrade package_name
```

### 更新所有包
```bash
source venv/bin/activate
pip list --outdated
pip install --upgrade -r requirements.txt
```

### 生成新的requirements.txt
```bash
source venv/bin/activate
pip freeze > requirements.txt
```

---

🎉 **总结**: 通过使用虚拟环境，我们可以完美解决macOS上的Python环境管理问题，确保项目依赖的隔离和一致性。
