#!/bin/bash

# =================================================================
# Aura Grid Lite — 极速无损自动更新工具 (国内加速/平滑升级)
# 用途: 一键拉取最新镜像、本地对齐标准标识并重启容器，安全释放空间
# 特性: 支持双轨雷达自寻径，在宿主机任意目录下均可直接执行升级
# 执行方式: curl -sSL http://auragrid.cn/UPDATE_LITE.sh | bash
# =================================================================

# 自动 Shell 提升
if [ -z "$BASH_VERSION" ]; then
    if command -v bash >/dev/null 2>&1 && [ -f "$0" ]; then
        exec bash "$0" "$@"
    fi
fi

set -e

# 颜色定义
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_msg() {
    printf "%b\n" "$1"
}

ALIYUN_IMAGE="crpi-z60uur6y0xgl3fgs.cn-chengdu.personal.cr.aliyuncs.com/aura-grid/aura-grid:latest"
GHCR_IMAGE="ghcr.io/24kbrother/aura-grid:latest"

print_msg "${BLUE}==================================================================${NC}"
print_msg "${GREEN} Aura Grid Lite —— 极速无损自动更新程序${NC}"
print_msg "${BLUE}==================================================================${NC}"

# 0. 环境检测
DOCKER_CMD="docker"
if [ "$(id -u 2>/dev/null || echo 0)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        DOCKER_CMD="sudo docker"
    fi
fi

if ! command -v docker >/dev/null 2>&1 && ! command -v sudo >/dev/null 2>&1; then
    print_msg "${RED}[ERROR] 未检测到 Docker 环境，请先确认 Docker 是否正在运行。${NC}"
    exit 1
fi

COMPOSE_CMD="$DOCKER_CMD compose"
if ! $DOCKER_CMD compose version >/dev/null 2>&1; then
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD="docker-compose"
    else
        print_msg "${RED}[ERROR] 未检测到 docker compose 核心组件。${NC}"
        exit 1
    fi
fi

# 1. 双轨雷达寻径：自动锁定 Aura Grid Lite 物理安装目录
TARGET_DIR=""
EXISTING_CONTAINER=$($DOCKER_CMD ps -a -q -f name=^aura-grid$ 2>/dev/null || true)

if [ -n "$EXISTING_CONTAINER" ]; then
    # 轨 A: Compose 物理工作区 Label
    LABEL_DIR=$($DOCKER_CMD inspect -f '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$EXISTING_CONTAINER" 2>/dev/null || true)
    if [ -n "$LABEL_DIR" ] && [ -d "$LABEL_DIR" ]; then
        TARGET_DIR="$LABEL_DIR"
    fi

    # 轨 B: 挂载点物理路径反推
    if [ -z "$TARGET_DIR" ]; then
        MOUNT_SRC=$($DOCKER_CMD inspect --format='{{range .Mounts}}{{if eq .Destination "/app/data"}}{{.Source}}{{end}}{{end}}' "$EXISTING_CONTAINER" 2>/dev/null || true)
        if [ -n "$MOUNT_SRC" ]; then
            CANDIDATE_DIR=$(dirname "$MOUNT_SRC")
            if [ -d "$CANDIDATE_DIR" ]; then
                TARGET_DIR="$CANDIDATE_DIR"
            fi
        fi
    fi
fi

# 轨 C: 当前目录自查
if [ -z "$TARGET_DIR" ] && [ -f "./docker-compose.yml" ]; then
    if grep -q 'aura-grid:' ./docker-compose.yml 2>/dev/null; then
        TARGET_DIR=$(pwd)
    fi
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    print_msg "${YELLOW}[WARNING] 未能在宿主机探测到已安装的 Aura Grid Lite 实例。${NC}"
    print_msg "如果您尚未安装过 Aura Grid Lite，请使用一键安装命令:"
    print_msg "  ${CYAN}curl -sSL http://auragrid.cn/LITE.sh | bash${NC}\n"
    exit 1
fi

print_msg "${BLUE}[*] 雷达已定位安装目录: ${TARGET_DIR}${NC}"
cd "$TARGET_DIR"

# 2. 安全备份重要数据
if [ -f "./data/device.id" ]; then
    cp "./data/device.id" "./data/device.id.bak" 2>/dev/null || true
fi

# 3. 极速拉取并本地打标
UPDATE_SUCCESS=false
print_msg "${BLUE}[*] 默认启用阿里云国内极速通道拉取最新镜像...${NC}"
if $DOCKER_CMD pull "$ALIYUN_IMAGE"; then
    print_msg "${BLUE}[*] 正在本地对齐官方容器标识...${NC}"
    $DOCKER_CMD tag "$ALIYUN_IMAGE" "$GHCR_IMAGE"
    $DOCKER_CMD rmi "$ALIYUN_IMAGE" >/dev/null 2>&1 || true
    UPDATE_SUCCESS=true
else
    print_msg "${YELLOW}[WARNING] 阿里云通道拉取遇到网络波动，正在为您尝试官方 GitHub 链路...${NC}"
    if $COMPOSE_CMD pull; then
        UPDATE_SUCCESS=true
    fi
fi

if [ "$UPDATE_SUCCESS" != "true" ]; then
    print_msg "${RED}[ERROR] 镜像拉取失败，请检查网络连接后重试。${NC}"
    exit 1
fi

# 4. 平滑更新容器
print_msg "${BLUE}[*] 正在平滑更新重启容器 (保留您的历史配置、数据与网络模式)...${NC}"
if $COMPOSE_CMD up -d; then
    print_msg "\n${GREEN}[SUCCESS] Aura Grid Lite 已成功更新并运行最新版本！${NC}"
    
    # 5. 安全释放旧版本占用的磁盘空间
    print_msg "${BLUE}[*] 正在自动清理被替换的旧版本镜像...${NC}"
    $DOCKER_CMD image prune -f >/dev/null 2>&1 || true
    print_msg "${GREEN}[SUCCESS] 磁盘空间已自动优化清理完毕！${NC}"

    IP_ADDR=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')
    if [ -z "$IP_ADDR" ]; then
        IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    [ -z "$IP_ADDR" ] && IP_ADDR="你的服务器IP"

    print_msg "\n${GREEN}==================================================${NC}"
    print_msg " 访问入口: ${BLUE}http://${IP_ADDR}:8125${NC}"
    print_msg " 工作目录: ${BLUE}${TARGET_DIR}${NC}"
    print_msg "${GREEN}==================================================${NC}\n"
else
    print_msg "${RED}[ERROR] 容器重启失败，请检查 ${TARGET_DIR}/docker-compose.yml 或查看日志: docker logs aura-grid${NC}"
    exit 1
fi
