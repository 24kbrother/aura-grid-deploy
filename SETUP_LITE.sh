#!/bin/bash

# =================================================================
# 🟢 Aura Grid - Lite 免费开源版安装脚本
# 用途: 首次安装 Aura Grid Lite 时的环境初始化与一键启动
# =================================================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 正在启动 Aura Grid Lite 部署流程...${NC}"

# 1. 基础环境检测
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 未检测到 Docker，请先安装 Docker。${NC}"
    exit 1
fi

INSTALL_DIR=$(pwd)

# 2. 初始化物理目录与设备指纹 (HWID)
echo -e "${BLUE}📂 正在初始化配置目录与生成设备指纹...${NC}"
mkdir -p "$INSTALL_DIR/data"
mkdir -p "$INSTALL_DIR/floorplans"
mkdir -p "$INSTALL_DIR/icons"
chmod -R 777 "$INSTALL_DIR/data" "$INSTALL_DIR/floorplans" "$INSTALL_DIR/icons"

HWID_FILE="$INSTALL_DIR/data/device.id"

if [ -f "$HWID_FILE" ]; then
    EXISTING_HWID=$(cat "$HWID_FILE")
    echo -e "${GREEN}✅ 检测到已有设备指纹: ${EXISTING_HWID}${NC}"
else
    # 生成通用 UUID
    NEW_HWID=$(cat /proc/sys/kernel/random/uuid)
    echo "$NEW_HWID" > "$HWID_FILE"
    echo -e "${GREEN}✨ 已生成全新设备指纹: ${NEW_HWID}${NC}"
fi

# 3. 生成 LITE 版 docker-compose.yml
echo -e "${BLUE}📦 正在生成 Docker 编排文件...${NC}"
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
    image: ghcr.nju.edu.cn/24kbrother/aura-grid:latest
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

# 4. 启动服务
echo -e "${BLUE}🌐 正在拉取镜像并启动服务...${NC}"
docker compose pull
docker compose up -d

# 5. 输出结果
IP_ADDR=$(hostname -I | awk '{print $1}')
echo -e "\n${GREEN}==================================================${NC}"
echo -e "🎉 Aura Grid Lite 部署成功！"
echo -e "--------------------------------------------------"
echo -e "🔹 访问入口: http://${IP_ADDR}:8125"
echo -e "🔹 您的设备 ID: $(cat "$HWID_FILE")"
echo -e "${GREEN}==================================================${NC}"
