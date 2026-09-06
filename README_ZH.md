[English](README.md) | **中文**

# 🌌 Aura Grid - 下一代智能家居视觉中控大屏

[![Version](https://img.shields.io/badge/version-v1.6.0--LITE-blue.svg)](https://github.com/24kbrother/aura-grid-deploy)
[![License](https://img.shields.io/badge/license-Commercial-red.svg)](https://vlanhub.com/buy)
[![Status](https://img.shields.io/badge/status-Production--Ready-green.svg)](https://vlanhub.com/buy)

**Aura Grid** 是一款高性能、高颜值、极致体验的智能家居视觉中控大屏引擎，专为 Home Assistant 打造。适用于各类硬件终端、触控平板、桌面副屏及移动设备。

---

## 🚀 一键快速启动 (LITE 开源免费版)

只需一行命令，即可在您的本地服务器（群晖 NAS、PVE、Unraid、Linux 服务器、树莓派等）上开启 Aura Grid 的极致体验：

### ⚡ 国内加速安装 / 更新（推荐 · 阿里云极速通道）
```bash
curl -sSL http://auragrid.cn/PULL_LITE_FROM_ALIYUN.sh | bash
```

### 🌐 官方通道（全量一键安装）
```bash
curl -sSL http://auragrid.cn/LITE.sh | bash
```

> 备用 GitHub 节点：
> ```bash
> curl -sSL https://raw.githubusercontent.com/24kbrother/aura-grid-deploy/main/SETUP_LITE.sh | bash
> ```

---

## 💎 Lite vs. Pro: 选择您的体验

| 功能特性 | LITE 免费版 (v1.6.0) | PRO 专业旗舰版 |
| :--- | :---: | :---: |
| 🤖 **智能管家 (AI Agent)** | **全量开放** (多模型接入 / Fast-Path 意图自愈 / HomeTools 工具库) | 完整支持 (含 PRO 专属深度情景感知) |
| 🔌 **MCP 智能硬件网关** | **支持** (Model Context Protocol / 小智 AI 与 ESP32 原生直连) | 完整支持 (多端并发与高频调度) |
| 💬 **即时通讯渠道** | **支持** (企业微信自建应用 + Telegram 机器人双渠道) | 完整支持 (含主动告警推送与群组联动) |
| 📱 **移动端 (Mobile) 体验** | 拟物化 3D 轮播 Teaser 引导体验 | **原生 iOS 26 竖屏中控 + HomeKit 胶囊导航 + 房间拖拽排序** |
| 🎨 **视觉美学 & 国际化** | 高级深色模式 + 简体/繁体/英文三语国际化 | **超丝滑流体微动效 + 玻璃拟态 + 黑胶唱片微件** |
| 🎛️ **设备控制 & 微件** | 基础开关/调光 + 抽屉式微件自适应 | **全品类支持 (高精度温控盘 / 倒三角水准仪热水器 / 动态能耗看板)** |
| 🏢 **多楼层支持** | 单楼层自适应布局 | **无限楼层平滑切换 + 楼层独立状态过滤** |
| 🛡️ **Aura Guard 安全** | 基础安全防护与配置自愈 | **3次失败 IP 熔断 + RSA 硬件指纹防伪 + Node-RED 秒级告警** |
| 🛎️ **智能门铃弹窗** | 基础告警提示 | **实时监控视频浮窗 + 一键滑动开锁联动** |
| 🤝 **技术与商业支持** | 社区开源支持 | **1v1 VIP 优先技术支持 + 专属升级通道** |

---

## 🤖 核心重磅：智能管家 (AI Agent) 与 MCP 网关全量下放

在 **v1.6.0-LITE** 中，Aura Grid 全面开放了智能管家核心引擎：
- **主流大模型零门槛接入**：支持 OpenAI 兼容、DeepSeek、Claude、通义千问 (Qwen)、MiniMax、豆包 (Doubao) 等主流服务商。
- **MCP 协议标准化直连**：开放 `/api/v1/mcp` JSON-RPC 端点，完美适配小智 AI、ESP32 等硬件语音助手。
- **Fast-Path 毫秒响应**：本地正则与意图自愈引擎，高频控制指令无需消耗大模型 Token 即可秒级直出。
- **全屋实体精准调度**：内置 HomeTools 智能工具库，精准调控灯光、温控、开关、场景等全量 Home Assistant 实体。

---

## 🛡️ Aura Guard 安全防护系统

为您的家庭中控终端筑牢隐形防线：
- **3-Strikes 熔断机制**：1 小时内连续 3 次登录失败自动触发 24 小时 IP 级封锁。
- **硬件指纹 (HWID) 审计**：端侧唯一硬件标识，保障配置隔离与安全追踪。
- **Node-RED 自动化联动**：安全异常秒级同步至 Home Assistant 手机端推送。

---

## 🛒 升级到 PRO 专业版

释放全屋智能中控的全部潜能，解锁移动端独立竖屏中控、高阶温控度盘、门铃视频弹窗与无限楼层无缝切换。

👉 **[获取 Aura Grid PRO 官方授权](https://vlanhub.com/buy)**

---

## 📞 支持与社区

- **视频教程**: [Bilibili 官方空间](https://space.bilibili.com/29908699)
- **文档中心**: [在线使用指南](https://24kbrother.github.io/aura-grid-deploy/)
- **密码找回**: [密码重置与账号恢复指南](https://24kbrother.github.io/aura-grid-deploy/#/password-reset-guide)
- **问题反馈**: [GitHub Issues](https://github.com/24kbrother/aura-grid-deploy/issues)
- **微信支持**: `china_24kbro`
- **官方邮箱**: [24k.brother@gmail.com](mailto:24k.brother@gmail.com)

---
*© 2026 Aura Grid & Aura Guard Security. 保留所有权利。*
