# 🧠 Aura Grid - Smart Home Interface

> **极致、流畅、高度自定义的智能家居“交互中台”。**  
> 官方部署指南 | [获取授权](#) | [加入社区](#)

---

## 🌟 项目简介

**Aura Grid (Shadow Smart Home)** 是一款为追求极致交互体验的用户打造的独立智能家居控制中台。它不仅仅是一个 Dashboard，更是一个连接 Home Assistant 与多种终端（iPad/Web/触摸屏）的高性能交互引擎。

### 核心亮点：
- **🚀 极速响应**：基于 NestJS + Redis 缓存，状态同步近乎零延迟。
- **📱 深度适配 iPad**：全屏 PWA 支持，原生级的长按与缩放手势优化。
- **📦 模块化微件**：支持热注入自定义 HTML/SFC 微件，随意定制你的面板。
- **📺 系统回忆录**：24 小时事件流滚动展示，家里的动静一目了然。

---

## 📸 视觉预览

![Floorplan](https://cdn.jsdelivr.net/gh/24kbrother/pic-assets/2.jpg)
![Floorplan](https://cdn.jsdelivr.net/gh/24kbrother/pic-assets/25.jpg)
![Floorplan](https://cdn.jsdelivr.net/gh/24kbrother/pic-assets/1.jpg)


---

## 🚀 快速启动 (Docker Compose)

### 1. 前置准备
- 已经安装 Docker & Docker Compose。
- 一个可用的 Home Assistant 实例，并已生成 **Long-lived Access Token**。

### 2. 下载部署文件
```bash
mkdir aura-grid && cd aura-grid
wget https://raw.githubusercontent.com/24kbrother/aura-grid-deploy/main/docker-compose.yml
mkdir data
mkdir floorplans
```
### 3. 启动系统
```bash
docker compose up -d
```
启动后，访问 `http://你的服务器IP:8125` 即可开启你的智能家居新篇章。

---

## 🛠️ 高级配置与自定义

系统支持通过配置文件定义热点区域和微件布局。详细文档请参考：
- 【待添加】[配置说明文档 (Wiki)](#)
- 【待添加】[如何创建自定义微件](#)

---

## 🛠️ 维护与卸载

如果您需要更新系统、清理旧版本镜像或彻底卸载，可以使用内置的自动化脚本：

### 1. 清理旧版本镜像 (仅清理)
当您部署了新版本的 Golden Image 后，可以运行以下命令移除系统中的旧镜像，释放磁盘空间：
```bash
docker image rm -f $(docker images | grep aura-grid | awk '{print $3}')
```

### 2. 一键卸载与彻底清理
我们提供了一个交互式的卸载脚本，支持自动停止容器并清理相关的 Docker 镜像。

**直接远程运行（推荐）：**
```bash
wget -O UNINSTALL.sh https://raw.githubusercontent.com/24kbrother/aura-grid-deploy/main/UNINSTALL.sh && bash UNINSTALL.sh
```

**或者本地运行：**
```bash
# 赋予执行权限并运行
chmod +x UNINSTALL.sh && ./UNINSTALL.sh
```

> [!CAUTION]
> **关于一键卸载脚本的重要提示：**
> 卸载脚本包含可选的 `docker system prune` 操作。这步操作是**全局性**的，会清理掉系统中**所有**未使用的网络和虚悬镜像。如果您同时运行着其他 Docker 项目，执行此操作前请务必确认已关闭或备份相关容器，以免误删。

---

## 🚀 开放测试与社区支持

目前 **Aura Grid** 处于公开测试阶段，所有核心功能**限时全量开放**给社区的小伙伴们体验。

我们非常看重你的反馈！如果在部署或使用过程中遇到任何问题，请随时联系：
- **反馈 Bug / 提建议**：请在 GitHub [Issues](https://github.com/24kbrother/aura-grid-deploy/issues) 留言。
- **技术支持与交流**：添加开发者微信 `china_24kbro`，备注“Aura Grid 公测”。
- **论坛讨论帖**：[翰思彼岸讨论帖](https://bbs.hassbian.com/thread-32016-1-1.html)

> [!TIP]
> 感谢每一位在公测阶段提供建议的朋友。你的反馈将直接决定后续版本的开发方向！

---

## 📄 免责声明
本项目基于 Home Assistant API 开发，请确保在安全的内网环境中使用。开发者不对由于配置不当导致的安全风险负责。

---
© 2026 Aura Grid Team. All rights reserved.
