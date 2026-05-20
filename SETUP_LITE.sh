#!/bin/bash

# =================================================================
# 🟢 Aura Grid - Lite 免费开源版安装脚本
# 用途: 首次安装 Aura Grid Lite 时的环境初始化与一键启动
# =================================================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN} 欢迎部署 AURA Grid —— 您的下一代智慧家居视觉中控系统${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e " 💡 当前正在为您安全部署：\033[1;32mLite 免费版\033[0m"
echo -e " ✨ 基础控制体验完全免费！若您希望探索「全量高级微件、多楼层无缝切换、云端联动」等极致功能："
echo -e "    可在系统初始化完成后，通过设置面板内的升级入口接入 \033[1;35mPRO 终身会员\033[0m。"
echo -e " ---------------------------------------------------------------------------"
echo -e ""
echo -e " ***************************************************************************************"
echo -e " * 🎁 \033[1;33m[早鸟特惠预警]\033[0m：当前限时锁定「一次付费、终身买断」，后续版本将全面恢复订阅制。   *"
echo -e " ***************************************************************************************"
echo -e ""
echo -e " 💬 官方技术支持通道："
echo -e "    WeChat: china_24kbro"
echo -e "    Email:  24k.brother@gmail.com"
echo -e "${BLUE}==================================================================${NC}\n"

# 1. 临时网络代理加速（可选，解决国内 ghcr.io 拉取慢）
IMAGE_HOST="ghcr.io"
read -p "是否需要配置临时 HTTP 代理加速拉取？(直接回车跳过，若需要请输入如 http://127.0.0.1:7890 ): " PROXY_URL </dev/tty
if [ -n "$PROXY_URL" ]; then
    export http_proxy=$PROXY_URL
    export https_proxy=$PROXY_URL
    export HTTP_PROXY=$PROXY_URL
    export HTTPS_PROXY=$PROXY_URL
    echo -e "${GREEN}[INFO] 临时网络代理配置成功。${NC}\n"
fi

echo -e "${BLUE}🚀 正在启动 Aura Grid Lite 部署流程...${NC}"

# 1.5 基础环境检测
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

CHECK_FILE="$INSTALL_DIR/data/check.id"
echo "1.5.6-LITE" > "$CHECK_FILE"
echo -e "${GREEN}✅ 部署环境自检标记已写入。${NC}"



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
    image: ${IMAGE_HOST}/24kbrother/aura-grid:latest
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

# 强制清理重名容器
docker rm -f aura-grid aura-redis &> /dev/null 

# 执行拉取
if ! docker compose pull; then
    echo -e "${RED}❌ 镜像拉取失败，请检查网络或代理设置。${NC}"
    exit 1
fi

# 执行启动，并捕获错误
if ! docker compose up -d; then
    echo -e "\n${RED}==================================================${NC}"
    echo -e "❌ 部署失败！"
    echo -e "--------------------------------------------------"
    echo -e "原因: 容器启动失败，可能是端口 8125 已被占用。"
    echo -e "建议: 执行 'netstat -tunlp | grep 8125' 检查端口占用。"
    echo -e "${RED}==================================================${NC}"
    exit 1
fi

# 5. 二次自检：确认容器是否真的在 Running 状态
if [ "$(docker inspect -f '{{.State.Running}}' aura-grid 2>/dev/null)" != "true" ]; then
    echo -e "${RED}❌ 警告：容器虽然已创建，但未能持续运行。请检查 Docker 日志。${NC}"
    exit 1
fi

# 只有通过了上面的层层校验，才会执行到这里
# 5. 输出结果
IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
# ... (IP 获取逻辑同上)

echo -e "\n${GREEN}==================================================${NC}"
echo -e "🎉 Aura Grid Lite 部署成功！"
# ... (输出详情)
