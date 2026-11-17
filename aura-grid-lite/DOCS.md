# Aura Grid Lite - Home Assistant 加载项使用指南

欢迎使用 **Aura Grid Lite** 开源全屋智能数字孪生控制中枢（HAOS / 冬瓜OS 官方加载项）。

---

## 特性概览

* **开源与免激活**：完全开源、零授权码、零硬件锁，即装即用；
* **极速免编译**：基于 GitHub GHCR 官方预构建多架构镜像（同时支持 `linux/arm64` 与 `linux/amd64`），一键拉取秒级安装；
* **原生 Ingress 无缝嵌入**：安装启动后自动进入 Home Assistant 左侧菜单栏，支持深层页面刷新与 WebSocket 实时状态流转；
* **单容器自闭环**：内嵌微型 Redis 守护服务与统一基准存储解析器，零外部依赖，极速开箱即用；
* **持久化守护**：系统数据（SQLite 数据库、用户自定义户型图、图标）全量持久化于 `/data` 卷，升级、备份与快照恢复 100% 保持无损；
* **看门狗自愈**：接入 Supervisor 原生 Watchdog，周期探测 `/health` 探针，服务异常自动拉起。

---

## 安装与使用流程

### 1. 添加应用商店仓库
1. 打开 Home Assistant 网页端，点击左侧菜单栏 **「设置 (Settings)」** → **「加载项 (Add-ons)」**（最新版 HA 中为 **「应用 (Apps)」**）；
2. 点击右下角 **「应用商店 (Add-on Store)」**；
3. 点击右上角菜单按钮 (`⋮`)，选择 **「存储库 (Repositories)」**；
4. 输入本仓库地址并点击添加：
   ```text
   https://github.com/24kbrother/aura-grid-deploy
   ```
5. 刷新页面，在商店列表中找到 **「Aura Grid Lite」** 卡片。

### 2. 首次启动与访问
1. 点击 **「安装 (Install)」**，Supervisor 将自动拉取适配您当前硬件架构的黄金镜像；
2. 勾选 **「在侧边栏中显示 (Show in sidebar)」** 与 **「开启监视狗 (Watchdog)」**；
3. 点击 **「启动 (Start)」**；
4. 启动完成后，直接在左侧边栏点击 **「Aura Lite」** 即可无缝进入全屋智能数字孪生界面！
5. **局域网访问与 App 直连**：默认通过宿主机端口 `8125` 暴露（`http://<HA-IP>:8125`），若端口冲突可在加载项「配置」页面自由修改。

---

## 连接 Home Assistant 核心

在 Aura Grid 首次设置向导或「系统设置 → 核心连接」中：
1. **Home Assistant 地址**：填写您的 HA 内网访问地址（如 `http://192.168.x.x:8123` 或 `http://homeassistant.local:8123`）；
2. **长期访问令牌 (Long-Lived Access Token)**：
   * 打开 HA「个人资料」页面（左下角用户头像）；
   * 滑动到底部「长期访问令牌」区域，点击「创建令牌」；
   * 复制 Token 并粘贴至 Aura Grid 配置面板，保存即可完成设备双向同步！

---

## 数据与备份策略

* **数据持久化位置**：所有业务数据安全保存在 Supervisor 管理的持久化卷 `/data`：
  * 数据库：`/data/prod.db`
  * 户型图：`/data/floorplans`
  * 自定义图标：`/data/icons`
* **系统备份与还原**：
  * 支持使用 HA 官方的「创建备份」功能；备份时将自动包含 `/data` 目录全部资产，重装或升级可一键恢复。
