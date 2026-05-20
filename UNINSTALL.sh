#!/bin/bash

# ══════════════════════════════════════════════════════════════════════
#  Aura Grid (Shadow Home) — 一键卸载与环境清理脚本
# ══════════════════════════════════════════════════════════════════════

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  正在启动 Aura Grid 环境清理与卸载程序...${NC}"

# 0. 检测 Docker Compose 命令
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}❌ 错误: 未检测到 Docker Compose，请手动清理容器。${NC}"
    exit 1
fi

# 1. 停止并移除容器、网络及匿名卷
echo -e "${GREEN}🛑 正在停止容器并移除网络...${NC}"
if [ -f "docker-compose.prod.yml" ]; then
    $DOCKER_COMPOSE -f docker-compose.prod.yml down --volumes --remove-orphans
elif [ -f "docker-compose.yml" ]; then
    $DOCKER_COMPOSE down --volumes --remove-orphans
else
    echo -e "${YELLOW}⚠️  未找到 docker-compose 文件，跳过容器停止阶段。${NC}"
fi

# 2. 移除 Aura Grid 相关镜像
echo -e "${GREEN}🧹 正在清理 Aura Grid 相关镜像...${NC}"
IMAGES=$(docker images --format "{{.Repository}} {{.ID}}" | grep "aura-grid" | awk '{print $2}' | sort -u)
if [ -n "$IMAGES" ]; then
    echo "发现相关镜像，正在移除..."
    docker image rm -f $IMAGES 2>/dev/null
else
    echo "✨ 未发现 Aura Grid 相关镜像。"
fi

# 3. 强力全局清理 (危险区)
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}🛑  高危操作确认：DOCKER 系统全局大扫除${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}注意：以下操作将执行 'docker system prune'，它的影响范围是全局的：${NC}"
echo -e " 1. 会删除【所有】已停止的容器（不仅限于 Aura Grid）。"
echo -e " 2. 会删除【所有】未被使用的 Docker 网络。"
echo -e " 3. 会删除【所有】虚悬镜像（Dangling Images）。"
echo -e " 4. 会清理【所有】构建缓存。"
echo ""
echo -e "${RED}警告：如果您还有其他正在运行或临时关闭的项目，此操作可能导致其数据/配置丢失。${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

read -p "❓ 您是否要执行此全局清理操作？(y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}♻️  正在执行全局大扫除...${NC}"
    docker system prune -f 2>/dev/null
    echo -e "${GREEN}✅ 全局清理完成。${NC}"
else
    echo -e "${YELLOW}⏩ 已跳过全局清理，仅卸载了 Aura Grid 本身。${NC}"
fi

echo ""
echo -e "${GREEN}------------------------------------------------------${NC}"
echo -e "✅ Aura Grid (Shadow Home) 已从 Docker 环境中卸载。"
echo ""
echo -e "${YELLOW}⚠️  温馨提示：${NC}"
echo -e "   1. 您的持久化配置（./data 和 ./floorplans 文件夹）仍保留在宿主机。"
echo -e "   2. 如需彻底删除所有数据（恢复出厂设置），请手动删除上述文件夹。"
echo -e "${GREEN}------------------------------------------------------${NC}"
