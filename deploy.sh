#!/bin/bash

# YTchat 一键部署脚本
# 使用方法: ./deploy.sh [production|development]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    log_success "Docker 环境检查通过"
}

# 检查环境变量文件
check_env() {
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            log_warning ".env 文件不存在，正在从 .env.example 复制..."
            cp .env.example .env
            log_warning "请编辑 .env 文件，配置必要的环境变量（特别是 YOUTUBE_API_KEY）"
            read -p "是否现在编辑 .env 文件？(y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ${EDITOR:-nano} .env
            fi
        else
            log_error ".env 文件不存在，请创建并配置环境变量"
            exit 1
        fi
    fi
    
    # 检查关键环境变量
    source .env
    if [ -z "$YOUTUBE_API_KEY" ] || [ "$YOUTUBE_API_KEY" = "your_youtube_api_key_here" ]; then
        log_error "请在 .env 文件中配置有效的 YOUTUBE_API_KEY"
        exit 1
    fi
    
    log_success "环境变量检查通过"
}

# 创建必要目录
create_directories() {
    log_info "创建必要目录..."
    mkdir -p data logs backup
    chmod 755 data logs backup
    log_success "目录创建完成"
}

# 部署应用
deploy() {
    local env=${1:-development}
    
    log_info "开始部署 YTchat (环境: $env)..."
    
    # 设置环境模式
    if [ "$env" = "production" ]; then
        export GIN_MODE=release
        log_info "使用生产环境配置"
    else
        export GIN_MODE=debug
        log_info "使用开发环境配置"
    fi
    
    # 停止现有服务
    log_info "停止现有服务..."
    docker-compose down --remove-orphans
    
    # 构建并启动服务
    log_info "构建并启动服务..."
    docker-compose up -d --build
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        log_success "服务启动成功！"
        log_info "访问地址: http://localhost:8080"
        
        # 显示服务状态
        echo
        log_info "服务状态:"
        docker-compose ps
        
        # 显示日志
        echo
        log_info "最近日志:"
        docker-compose logs --tail=20
        
    else
        log_error "服务启动失败，请检查日志"
        docker-compose logs
        exit 1
    fi
}

# 备份数据
backup() {
    log_info "备份数据库..."
    local backup_file="backup/ytchat_$(date +%Y%m%d_%H%M%S).db"
    
    if [ -f "data/ytchat.db" ]; then
        cp data/ytchat.db "$backup_file"
        log_success "数据库备份完成: $backup_file"
    else
        log_warning "数据库文件不存在，跳过备份"
    fi
}

# 显示帮助信息
show_help() {
    echo "YTchat 部署脚本"
    echo
    echo "使用方法:"
    echo "  ./deploy.sh [选项] [环境]"
    echo
    echo "环境:"
    echo "  production   生产环境部署"
    echo "  development  开发环境部署 (默认)"
    echo
    echo "选项:"
    echo "  --backup     部署前备份数据"
    echo "  --help       显示帮助信息"
    echo
    echo "示例:"
    echo "  ./deploy.sh production"
    echo "  ./deploy.sh --backup production"
}

# 主函数
main() {
    local do_backup=false
    local environment="development"
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backup)
                do_backup=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            production|development)
                environment=$1
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_info "开始 YTchat 部署流程..."
    
    # 执行检查
    check_docker
    check_env
    create_directories
    
    # 备份（如果需要）
    if [ "$do_backup" = true ]; then
        backup
    fi
    
    # 部署
    deploy "$environment"
    
    log_success "部署完成！"
    echo
    log_info "常用命令:"
    echo "  查看日志: docker-compose logs -f"
    echo "  重启服务: docker-compose restart"
    echo "  停止服务: docker-compose down"
    echo "  更新服务: ./deploy.sh $environment"
}

# 运行主函数
main "$@"