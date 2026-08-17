# 🚀 Aura Grid Release Notes

---

## 🌟 [v1.6.0-LITE] - 2026-08-17 (Golden Milestone)

### 🤖 1. 智能管家 (AI Agent) 核心架构全量下放
- **多模型生态接入**：原生集成 OpenAI 兼容、DeepSeek、Claude、通义千问 (Qwen)、MiniMax、豆包 (Doubao) 等主流大模型适配器。
- **Fast-Path 意图自愈引擎**：针对开关、调光、模式切换等高频设备指令，引入毫秒级本地正则与模糊意图匹配，无需消耗大模型 Token 即可秒级直出。
- **HomeTools 全屋实体工具库**：深度绑定 Home Assistant 实体状态机，提供灯光、空调、热水器、开关、场景等多品类设备的自动化与智能调度。

### 🔌 2. MCP (Model Context Protocol) 智能硬件网关
- **标准 JSON-RPC 网关端点**：开放 `/api/v1/mcp` 端点，完整支持 `initialize`、`tools/list`、`tools/call`、`ping` 等全套生命周期协议。
- **开源智能硬件生态联动**：无缝对接小智 AI 桌面终端、ESP32 语音客户端，打破传统大屏与桌面硬件的交互壁垒。

### 💬 3. 即时通讯 (IM) 双渠道深度集成
- **企业微信自建应用 (WeCom)**：支持加解密验签、被动文本回复与主动语音/控制指令解析，随时随地通过企业微信管理家中状态。
- **Telegram 机器人**：支持 Long Polling 长轮询与 Webhook 双模式，内置用户白名单安全鉴权防串台。

### 📱 4. 移动端拟物化分流与视口智能感知
- **智能视口自适应**：手机竖屏访问时自动切换至拟物化 Teaser 引导视图，告别缩放版横屏中控的不便。
- **高保真纯 CSS 拟物化轮播**：呈现 Home、Rooms、Doorbell 与 Energy 4 大场景 Mockup，提供丝滑的升级与接入指引。

### 🌐 5. 国际化与微件抽屉全面对齐
- **三语完整适配**：简体中文 (zh-CN)、繁体中文 (zh-TW)、英语 (en) 词条 100% 补齐，支持浏览器首选语言智能首发识别。
- **微件抽屉布局优化**：修复抽屉内配置项在小尺寸屏幕上的换行问题，增强 UI 视觉稳健度。

### ⚡ 6. 阿里云容器镜像 (Aliyun ACR) 国内极速通道
- **双仓库镜像分发**：同步推送到 GitHub Container Registry (`ghcr.io`) 与阿里云容器镜像服务 (`crpi-z60uur6y0xgl3fgs.cn-chengdu.personal.cr.aliyuncs.com`)。
- **一键极速拉取与自愈更新**：
  ```bash
  curl -sSL http://auragrid.cn/PULL_LITE_FROM_ALIYUN.sh | bash
  ```

---

## 📦 版本信息 (Version Matrix)
- **Frontend**: `1.6.0` (`v1.6.0-LITE`)
- **Backend**: `1.6.0` (`v1.6.0-LITE`)
- **GHCR Image**: `ghcr.io/24kbrother/aura-grid:v1.6.0-LITE` / `latest`
- **Aliyun Image**: `crpi-z60uur6y0xgl3fgs.cn-chengdu.personal.cr.aliyuncs.com/aura-grid/aura-grid:v1.6.0-LITE` / `latest`

---

## 📜 历史版本记录 (Historical Releases)

### [v1.5.0] - 2026-04-10
- **全新品牌标识**：引入高精度矢量 Logo 与现代毛玻璃 UI 规范。
- **热区交互安全锁**：楼层切换器与画布微件增加物理安全防误触开关。
- **GPU 渲染大幅优化**：消除层叠爆炸，模板依赖追踪降至 $O(1)$。

### [v1.4.16-STABLE] - 2026-03-28
- **NestJS 11 / Express 5 路由修复**：升级 `path-to-regexp` v6 兼容命名通配符。
