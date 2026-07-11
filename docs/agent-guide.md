# AI 智能管家配置指南

Aura Grid Pro v1.8.18+ 内置 AI 智能管家，支持自然语言控制全屋设备。

---

## 一、功能概览

| 能力 | 示例 |
|---|---|
| 单设备控制 | "打开客厅灯带" |
| 房间批量控制 | "打开书房所有灯" |
| 全屋控制 | "关闭所有灯" |
| 温度调节 | "主卧空调调到24度" |
| 环境查询 | "书房几度"、"客厅湿度多少" |
| 复合指令 | "开灯带和主灯" |
| 场景开关 | 支持 `input_boolean` 虚拟开关 |

---

## 二、配置大模型

AI 智能管家需要一个大模型来理解自然语言指令。设置路径：**大屏设置 → 智能管家 → 编辑配置**。

### 支持的模型提供商

| 提供商 | 默认模型 | 费用 | 推荐场景 |
|---|---|---|---|
| **DeepSeek** | deepseek-v4-flash | 免费额度 | ⭐ 推荐，免费且低延迟 |
| 豆包 (ByteDance) | doubao-1-5-pro-32k | 按量付费 | 国内用户首选 |
| 通义千问 (Alibaba) | qwen-plus | 按量付费 | 阿里云生态用户 |
| MiniMax | MiniMax-M2.5 | 按量付费 | 可选 |
| Moonshot | moonshot-v1-8k | 按量付费 | 可选 |
| 自定义 | 自行填写 | 自定 | 本地部署 / 其他 OpenAI 兼容 API |

### 配置步骤

1. 选择模型提供商（系统自动填充 API 地址和推荐模型）
2. 填入 API Key（在对应平台申请）
3. 选择回复语言（中文 / English）
4. 点击保存

> ⚡ 保存即刻生效，无需重启容器。

### 各平台 API Key 获取地址

| 平台 | 申请地址 |
|---|---|
| DeepSeek | [platform.deepseek.com](https://platform.deepseek.com) → API Keys |
| 豆包 | [console.volcengine.com/ark](https://console.volcengine.com/ark) → API Key 管理 |
| 通义千问 | [dashscope.console.aliyun.com](https://dashscope.console.aliyun.com) → API-KEY 管理 |
| MiniMax | [platform.minimax.chat](https://platform.minimax.chat) → API 密钥 |
| Moonshot | [platform.moonshot.cn](https://platform.moonshot.cn) → API Keys |

---

## 三、添加消息渠道

配置好大模型后，需要添加消息渠道才能远程与智能管家对话。

| 渠道 | 难度 | 需要公网 | 指南 |
|---|---|---|---|
| **Telegram** | ⭐ 简单 | ❌ 不需要 | [Telegram 配置指南](telegram-setup.md) |
| 企业微信 | ⭐⭐⭐ 复杂 | ✅ 需要 | 需自建应用 + 公网回调 |

> 推荐从 Telegram 开始，5 分钟就能配好开始用。

---

## 四、使用方式

### Telegram

给 Bot 发文字消息，Bot 自动调用智能管家执行指令。详见 [Telegram 配置指南](telegram-setup.md)。

### 企业微信

通过企业微信自建应用收发消息，适合有公网服务器的用户。

### 语音硬件（开发中）

ESP32-S3 物理语音硬件正在开发，未来支持本地唤醒词 + 语音对话，敬请期待。

---

## 五、费用说明

| 场景 | 代价 |
|---|---|
| 简单指令（开灯/关灯/查温度） | **0 Token** — 快路径规则匹配，不调用大模型 |
| 复杂/歧义指令 | 约 ¥0.001~0.003/次 — 走大模型 |
| 同一句话第二次说 | **0 Token** — 自学习缓存命中 |
| 未配置 API Key | 模拟模式，不花钱只能回固定话术 |

> 普通家庭日常使用，每月费用约为 **几分钱到几毛钱**。

---

## 六、安全

- **高危设备禁控**：门锁、安防、燃气类设备不允许通过语音/消息控制
- **API Key 红点保护**：已配置的 Key 前端永远不可见
- **白名单控制**：Telegram 支持按用户/ID 限制访问权限

---

*下一步：[Telegram 配置指南](telegram-setup.md)*
