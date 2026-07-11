# Telegram 消息渠道配置指南

通过 Telegram Bot 实现远程自然语言控制智能家居，无需公网 IP、无需端口转发。

---

## 一、前置条件

- Aura Grid Pro **v1.8.18+**（设置页 → 系统维护 可查看版本）
- 一个 Telegram 账号
- 手机或电脑已安装 Telegram

---

## 二、创建 Telegram Bot（2 分钟）

### 步骤 1：找到 BotFather

在 Telegram 中搜索 `@BotFather`，这是 Telegram 官方的 Bot 管理机器人。认准蓝色认证标识。

### 步骤 2：创建 Bot

给 BotFather 发送以下命令：

```
/newbot
```

### 步骤 3：设置名称

BotFather 会询问两个名字：

| 名称类型 | 说明 | 示例 |
|---|---|---|
| **显示名称** | 用户在对话列表看到的名字 | `Aura 智能管家` |
| **用户名** | Bot 的唯一 ID，必须以 `bot` 结尾 | `aura_guard_bot` |

> 💡 用户名必须是全网唯一的。如果提示被占用，换一个即可。

### 步骤 4：获取 Token

创建成功后，BotFather 会返回一段消息，其中包含：

```
Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

**复制这串 Token**，下一步要用。

---

## 三、在 Aura Grid 中配置（1 分钟）

### 步骤 1：打开智能管家设置

Aura Grid 大屏 → 设置 → 智能管家

### 步骤 2：添加 Telegram 渠道

点击「新增渠道」→ 选择 **Telegram**

### 步骤 3：填入配置

| 字段 | 填写内容 |
|---|---|
| **Bot Token** | 粘贴上一步从 BotFather 获取的 Token |
| **允许的用户** | 填写你的 Telegram 用户名（`@` 后面的部分），多个用逗号分隔。留空则不限制 |
| **Webhook URL** | ⚠️ **留空即可**（家庭内网环境不需要） |

### 步骤 4：保存

点击「保存」，看到下拉提示「已生效」或「保存成功」即完成。

> 保存后无需重启，Bot 在 3 秒内自动上线。

---

## 四、开始使用

### 找到你的 Bot

在 Telegram 搜索你刚才创建的用户名（如 `@aura_guard_bot`），点击 **Start（开始）** 按钮。

### 发送指令

直接给 Bot 发文字消息即可，例如：

| 你说 | Bot 做什么 |
|---|---|
| `打开客厅灯` | 打开客厅所有灯具 |
| `关闭所有灯` | 关闭全屋灯具 |
| `书房几度` | 查询书房温度 |
| `主卧空调调到 24 度` | 设置空调温度 |
| `开灯带和主灯` | 同时执行多个操作 |

Bot 执行成功后会回复随机话术（"搞定了"、"收到"、"安排上了" 等）。

---

## 五、白名单配置（可选）

如果想限制只有特定用户能控制，在「允许的用户」字段填写用户名：

```
zhangsan, lisi, 971978126
```

支持三种格式：
- Telegram 用户名（不带 `@`）
- 用户数字 ID（在 Telegram 设置中查看）
- 混合填写，逗号分隔

留空则任何人都可以发指令给你的 Bot。

> 🔒 安全提示：白名单建议开启。虽然 Bot Token 不容易泄露，但加上白名单多一层保护。

---

## 六、常见问题

### Q: Bot 不回复消息？

1. 确认 Bot Token 填写正确（不能有空格、换行）
2. 确认你已经给 Bot 点了 **Start**
3. 查看 Aura Grid 后端日志：`docker logs aura-grid-pro | grep Telegram`

### Q: 能不能让 Bot 进群聊？

可以。在 BotFather 发送 `/setjoingroups` → 选择你的 Bot → 设为 **Enable**。然后把 Bot 拉进群并设为管理员即可。群聊中使用时需要 `@你的Bot名字 指令` 或在白名单中填写群聊 ID。

### Q: 需要公网 IP 吗？

**不需要。** Telegram 使用 Polling（轮询）模式，Aura Grid 主动去 Telegram 服务器取消息，无需公网可达。即使你的服务器在家里 NAS 上，没有固定 IP，也完全可用。

### Q: 消息延迟大吗？

通常 1~3 秒。这是 Polling 模式的正常延迟。对于"开灯"这类指令完全无感知。如需更低延迟（毫秒级），可配置 Webhook URL（需要公网 HTTPS）。

### Q: Token 泄漏了怎么办？

去 BotFather 发送 `/revoke` → 选择你的 Bot → BotFather 生成新 Token。把新 Token 更新到 Aura Grid 设置页即可，旧 Token 立即失效。

---

## 七、进阶

### 绑定多个 Bot

Aura Grid 目前支持配置 **一个 Telegram Bot**。如需多个 Bot（如家庭成员各有自己的 Bot），可在 BotFather 创建多个 Bot，但目前 UI 仅支持配置一个。多 Bot 支持规划中。

### Webhook 模式

有公网服务器 + HTTPS 证书的用户，可在「Webhook URL」填入：

```
https://你的域名:8125/api/v1/telegram/webhook
```

填了以后自动切换为 Webhook 推送模式，消息延迟降至毫秒级。留空则使用 Polling 模式。

---

*相关：你也可以同时配置企业微信渠道，实现双通道消息控制。详见企业微信配置指南。*
