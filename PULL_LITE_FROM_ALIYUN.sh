#!/bin/bash
# =================================================================
# 🟢 Aura Grid Lite — 阿里云国内极速通道拉取/升级/自愈部署脚本
# 适用场景: 
#   1. 老用户更新: 秒级拉取阿里云镜像并平滑重启容器
#   2. 空白目录误跑: 自动自愈补齐目录与设备指纹(HWID)，完成全新极速安装
# =================================================================

BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ALIYUN_IMAGE="crpi-z60uur6y0xgl3fgs.cn-chengdu.personal.cr.aliyuncs.com/aura-grid/aura-grid:latest"
GHCR_IMAGE="ghcr.io/24kbrother/aura-grid:latest"
INSTALL_DIR=$(pwd)

echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN} 🚀 Aura Grid Lite —— 阿里云国内极速拉取与平滑更新${NC}"
echo -e "${BLUE}==================================================================${NC}"

# 1. 基础环境检测
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 未检测到 Docker，请先安装 Docker。${NC}"
    exit 1
fi

# 2. 检查当前目录下是否有 docker-compose.yml (自愈防呆)
if [ ! -f "$INSTALL_DIR/docker-compose.yml" ]; then
    echo -e "${YELLOW}⚠️  检测到当前目录尚未初始化，正在为您自动转入【全新极速部署】流程...${NC}"
    
    # 初始化物理目录与权限
    mkdir -p "$INSTALL_DIR/data" "$INSTALL_DIR/floorplans" "$INSTALL_DIR/icons"
    chmod -R 777 "$INSTALL_DIR/data" "$INSTALL_DIR/floorplans" "$INSTALL_DIR/icons"

    # 设备指纹 (HWID) 预制与防丢失保护
    HWID_FILE="$INSTALL_DIR/data/device.id"
    if [ -f "$HWID_FILE" ]; then
        EXISTING_HWID=$(cat "$HWID_FILE")
        echo -e "${GREEN}✅ 检测到已有设备指纹: ${EXISTING_HWID}${NC}"
    else
        if [ -f /proc/sys/kernel/random/uuid ]; then
            NEW_HWID=$(cat /proc/sys/kernel/random/uuid)
        else
            NEW_HWID="aura-lite-$(date +%s)"
        fi
        echo "$NEW_HWID" > "$HWID_FILE"
        echo -e "${GREEN}✨ 已生成全新设备指纹: ${NEW_HWID}${NC}"
    fi

    # 自检标记
    echo "1.6.0-LITE" > "$INSTALL_DIR/data/check.id"

    # 自动生成标准 docker-compose.yml
    cat <<EOF > "$INSTALL_DIR/docker-compose.yml"
services:
  redis:
    image: redis:7-alpine
    container_name: aura-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - aura-internal

  aura-grid:
    image: ghcr.io/24kbrother/aura-grid:latest
    container_name: aura-grid
    restart: unless-stopped
    environment:
      NODE_ENV: production
      PORT: 8500
      REDIS_URL: redis://redis:6379
      DATABASE_URL: file:/app/prisma/data/prod.db
      FLOORPLANS_DIR: /app/floorplans
    volumes:
      - db_data:/app/prisma/data
      - ./floorplans:/app/floorplans
      - ./icons:/app/icons
      - ./data:/app/data
    ports:
      - "8125:8500"
    networks:
      - aura-internal
    depends_on:
      - redis

networks:
  aura-internal:
    driver: bridge

volumes:
  redis_data:
    name: aura-redis-data
  db_data:
    name: aura-db-data
EOF
    echo -e "${GREEN}✅ 编排文件自愈生成完成。${NC}"
fi

# 3. 从阿里云极速拉取并本地对齐
echo -e "${BLUE}[*] 正在通过阿里云国内极速通道拉取最新 LITE 镜像...${NC}"
if docker pull "$ALIYUN_IMAGE"; then
    echo -e "${BLUE}[*] 正在本地对齐官方容器标识...${NC}"
    if docker tag "$ALIYUN_IMAGE" "$GHCR_IMAGE"; then
        docker rmi "$ALIYUN_IMAGE" >/dev/null 2>&1 || true
        echo -e "${GREEN}[SUCCESS] 最新镜像已成功就绪！${NC}"
        echo -e "🔹 镜像标识: ${GREEN}$GHCR_IMAGE${NC}\n"
    else
        echo -e "${RED}[ERROR] 镜像本地打标对齐失败。${NC}"
        exit 1
    fi
else
    echo -e "${RED}[ERROR] 从阿里云极速通道拉取镜像失败，请检查网络。${NC}"
    exit 1
fi

# 4. 智能更新询问交互
echo -e "\033[1;33m----------------------------------------------------------------\033[0m"
echo -e "🚀 镜像已拉取完毕。是否现在立即重启并更新容器到最新版？"
echo -e "👉 \033[1;32m按 [回车] 或输入 Y 立即更新\033[0m | \033[0;37m输入 N 或按 Ctrl+C 稍后手动更新\033[0m"
echo -e "\033[1;33m----------------------------------------------------------------\033[0m"

CONFIRM="Y"
if [ -t 0 ]; then
    read -p "请选择 [Y/n] (默认: Y): " INPUT_CHOICE
else
    if [ -e /dev/tty ]; then
        read -p "请选择 [Y/n] (默认: Y): " INPUT_CHOICE </dev/tty
    fi
fi

CHOICE="${INPUT_CHOICE:-Y}"

if [[ "$CHOICE" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}[*] 正在启动/重启 Aura Grid Lite 容器...${NC}"
    
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    elif docker-compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker-compose"
    else
        echo -e "${RED}[!] 未检测到 docker compose 命令，请手动执行更新。${NC}"
        exit 0
    fi

    if $COMPOSE_CMD up -d; then
        echo ""
        echo -e "${GREEN}🎉 Aura Grid Lite 已成功更新并运行最新版本！${NC}"
        
        echo -e "${BLUE}[*] 正在自动释放旧版本镜像空间...${NC}"
        docker image prune -f >/dev/null 2>&1 || true
        echo -e "${GREEN}✔ 系统空间已自动优化清理完毕！${NC}"
        
        IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
        [ -z "$IP_ADDR" ] && IP_ADDR="你的服务器IP"
        echo -e "\n${GREEN}==================================================${NC}"
        echo -e "🌐 访问地址: http://${IP_ADDR}:8125"
        echo -e "${GREEN}==================================================${NC}\n"
    else
        echo -e "${RED}[!] 容器启动遇到问题，请检查当前目录下的 docker-compose.yml。${NC}"
    fi
else
    echo ""
    echo -e "\033[0;36m[已跳过自动更新]\033[0m 如需稍后手动启动新镜像，请在当前目录下运行："
    echo -e "   \033[1;37mdocker compose up -d\033[0m"
fi
