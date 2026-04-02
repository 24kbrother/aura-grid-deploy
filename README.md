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

![Floorplan](https://cdn.jsdelivr.net/gh/24kbrother/aura-grid-assets/forum/main_dashboard.jpg)
*(注：请在 PicGo 上传后替换此处的图床链接)*

---

## 🚀 快速启动 (Docker Compose)

### 1. 前置准备
- 已经安装 Docker & Docker Compose。
- 一个可用的 Home Assistant 实例，并已生成 **Long-lived Access Token**。

### 2. 下载部署文件
```bash
mkdir aura-grid && cd aura-grid
wget https://raw.githubusercontent.com/24kbrother/aura-grid-deploy/main/docker-compose.yml
wget https://raw.githubusercontent.com/24kbrother/aura-grid-deploy/main/.env.example
cp .env.example .env
```

### 3. 配置环境变量
编辑 `.env` 文件，填入你的 HA 地址和 Token：
```bash
HA_URL=http://你的HA地址:8123
HA_TOKEN=你的长效访问令牌
ACCESS_PASSWORD=123456
```

### 4. 启动系统
```bash
docker-compose up -d
```
启动后，访问 `http://你的服务器IP:8500` 即可开启你的智能家居新篇章。

---

## 🛠️ 高级配置与自定义

系统支持通过配置文件定义热点区域和微件布局。详细文档请参考：
- [配置说明文档 (Wiki)](#)
- [如何创建自定义微件](#)

---

## 🔒 商业授权与支持

Aura Grid 是一个闭源商业项目。你可以免费部署基础版本进行体验。如需获取以下高级功能，请联系开发者获取 **商业授权码**：
- **[ ] 多项目并行管理**
- **[ ] 深度视觉定制服务**
- **[ ] 优先技术支持与更新**

**联系方式：**
- 微信：`[此处填写你的微信号]`
- 论坛：[翰思彼岸讨论帖](https://bbs.hassbian.com/...)

---

## 📄 免责声明
本项目基于 Home Assistant API 开发，请确保在安全的内网环境中使用。开发者不对由于配置不当导致的安全风险负责。

---
© 2026 Aura Grid Team. All rights reserved.
