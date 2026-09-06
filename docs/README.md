# Aura Grid Developer Center / 开发者中心

Welcome to the Aura Grid Developer Hub. This center provides full technical specifications, layout guides, API structures, and copy-paste templates to help you customize and program your dashboard interfaces in real time.

欢迎来到 Aura Grid 开发者中心。本中心提供完整的技术规范、布局指南、API 结构以及即插即用的组件模板，帮助您实时定制和编程您的大屏控制面板。

---

## 1. AI Agent / AI 智能管家

Configure the built-in AI butler with natural language smart home control via Telegram and WeCom messaging channels.

配置内置的 AI 智能管家，通过 Telegram / 企业微信消息渠道实现自然语言智能家居控制。

*   [**智能管家配置指南 (Agent Setup)**](agent-guide.md)
*   [**Telegram 渠道配置 (Telegram Setup)**](telegram-setup.md)

---

## 2. Sidebar Custom Swiper / 侧边栏混合滑动微件

Program custom components rendered within isolated sandboxed containers inside the sidebar widgets, communicating directly with your Home Assistant entities.

在侧边栏微件的隔离容器中编写您的自定义 HTML/CSS/JS 代码，与您的 Home Assistant 实体进行零延迟双向通信。

*   [**中文配置指南 (Chinese Guide)**](custom-widget-guide.md)
*   [**English Development Manual**](custom-widget-guide-en.md)

---

## 3. Aura Floating Hub (AFH) / 悬浮图层系统微件

Overlay advanced floating cards (e.g. status bubbles, lighting monitors, or quick-action rings) above the main dashboard canvas with active drag-and-drop support.

在大屏幕主画布之上叠加高级悬浮卡片（如状态泡泡、灯具监控器或快捷操作环），支持百分比坐标的自由拖拽定位。

*   [**中文配置指南 (Chinese Guide)**](afh-custom-guide.md)
*   [**English Development Manual**](afh-custom-guide-en.md)

---

## 4. Maintenance & Recovery / 运维与账号恢复

Recover access or reset administrator credentials without losing dashboard configurations.

在忘记管理员密码或需要重置凭据时自主恢复访问，且 100% 保持大屏与户型图配置完好。

*   [**密码重置与账号找回指南 (Chinese Guide)**](password-reset-guide.md)
*   [**Password Reset & Recovery Manual (English)**](password-reset-guide-en.md)

---

## 5. Visual Specifications / 视觉规范

To maintain visual consistency with the high-tech, futuristic dark UI:
1. Always utilize the transparent, frosted glass aesthetics with `backdrop-filter: blur(12px)`.
2. Apply standard border elements: `border: 1px solid rgba(255, 255, 255, 0.08)`.
3. Use bright primary colors (Cyan, Royal Blue, Neon Amber, Emerald) solely for active status highlighting and indicators.

为了保持与高科技、未来感深色大屏的视觉一致性：
1. 始终使用 `backdrop-filter: blur(12px)` 保持毛玻璃半透明美感。
2. 使用统一的极细边框：`border: 1px solid rgba(255, 255, 255, 0.08)`。
3. 状态激活时推荐使用高亮纯色（青色、宝蓝、霓虹琥珀、翡翠绿）作为呼吸灯或指示器。

