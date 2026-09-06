# 🔐 密码重置与账号找回指南 (Password Reset Guide)

> 本指南适用于 **Aura Grid LITE (开源免费版)** 与 **PRO 专业版**。  
> 当您忘记管理员登录密码或需要重设账号时，可通过宿主机或 NAS 终端自主完成秒级恢复。  
> **重要保证：重置密码 100% 不会丢失任何大屏布局、3D 户型图与设备绑定配置。**

---

## 💡 数据安全说明 (Data Safety)

Aura Grid 在底层架构设计上实现了**用户鉴权**与**大屏配置**的物理隔离：
- **管理员账号信息**：仅保存在数据库的 `User` 表中（仅存储用户名与加密哈希）。
- **大屏布局与业务数据**：全量 3D 户型图、卡片排版、微件状态、Home Assistant 连接凭据等均持久化保存在独立的 `ProjectConfig` 配置表中。

因此，无论是一键改密还是清空用户表重新运行向导，您精心配置的系统界面均完好无损。

---

## 🛠️ 方案一：Docker 终端一键改密（推荐 · 零停机秒生效）

这是最推荐、最无感的恢复方式。无需重启容器，直接调用容器内环境执行加盐哈希更新。

### 步骤 1：确认容器名称
默认容器名称为 `aura-grid`。如果不确定，在宿主机终端执行：
```bash
docker ps --filter "name=aura-grid" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

### 步骤 2：查看当前管理员用户名（若用户名也遗忘）
执行以下命令直接读取当前系统的管理员用户名：
```bash
docker exec -it aura-grid node -e '
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
prisma.user.findMany().then(users => {
  console.log("当前系统管理员账号:", users.map(u => u.username));
}).finally(() => prisma.$disconnect());
'
```

### 步骤 3：一键设置新密码
将下方命令中的 `新密码123456` 改为您想要的新密码，复制到终端运行：
```bash
docker exec -it aura-grid node -e '
const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
async function main() {
  const newPassword = "新密码123456"; // 👈 修改为您想要设置的新密码
  
  const hash = await bcrypt.hash(newPassword, 10);
  const user = await prisma.user.findFirst();
  if (user) {
    await prisma.user.update({
      where: { id: user.id },
      data: { password: hash }
    });
    console.log("=========================================");
    console.log("✅ 密码重置成功！");
    console.log("👉 登录用户名:", user.username);
    console.log("👉 新密码已即刻生效，请直接在网页端登录！");
    console.log("=========================================");
  } else {
    console.log("⚠️ 未检测到用户记录，请通过方案二重新初始化系统。");
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
'
```
执行完毕后直接在浏览器输入新密码登录，**无需重启容器**。

---

## 🔄 方案二：清空用户表，回到网页初始化向导（最直观）

Aura Grid 内置了系统自愈感知机制：**当数据库中管理员数量为 0 时，前端访问会自动重定向至首次安装向导（`/setup`）**。

### 步骤 1：清空旧凭据
在宿主机执行以下命令：
```bash
docker exec -it aura-grid node -e '
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
prisma.user.deleteMany().then(r => {
  console.log("=========================================");
  console.log("✅ 管理员状态已重置（已清除旧用户）");
  console.log("👉 户型图、卡片排版、微件等配置 100% 完好保留！");
  console.log("👉 请刷新浏览器访问 Aura Grid，页面将自动进入初始设置向导！");
  console.log("=========================================");
}).finally(() => prisma.$disconnect());
'
```

### 步骤 2：浏览器重新创建账号
1. 打开浏览器刷新 Aura Grid 大屏页面；
2. 系统自动呈现欢迎向导（`/setup`）；
3. 输入您期望的**新用户名与新密码**并提交；
4. 提交后系统自动登录，原有的大屏布局原封不动、无缝恢复。

---

## 🗄️ 方案三：直接操作挂载的 SQLite 数据库文件（备用）

在官方 `docker-compose.yml` 部署中，数据库持久化存储在宿主机当前目录的 `./data/prod.db`。若宿主机安装了 `sqlite3` 工具，可直接在宿主机执行：

```bash
# 进入 docker-compose 部署所在目录
cd /path/to/aura-grid-deploy

# 清空 User 表以恢复初始化向导
sqlite3 ./data/prod.db "DELETE FROM User;"
```
清空后刷新网页，即可重新设置管理员。

---

## 🖥️ 特殊环境操作指引 (群晖 NAS / 威联通 / 宝塔 / 1Panel)

### 1. 群晖 DSM / 威联通 QNAP / 极空间
1. 打开 NAS 的 **Container Manager** (或 Docker 管理器)；
2. 找到运行中的 `aura-grid` 容器，点击「操作」->「打开终端机」或「执行命令」；
3. 新增一个 `sh` 命令行终端；
4. 直接粘贴方案一或方案二中 `node -e '...'` 的单引号脚本代码段（去掉外层的 `docker exec -it aura-grid`）并回车执行。

### 2. 宝塔面板 / 1Panel
1. 进入「Docker / 容器」管理页面；
2. 找到 `aura-grid` 容器，点击右侧「终端」；
3. 粘贴上述 `node -e '...'` 脚本并运行。

---

## ❓ 常见问题 (FAQ)

#### Q1: 提示 `Error: No such container: aura-grid`？
说明您的容器名称不叫 `aura-grid`。请执行 `docker ps` 查看当前的真实容器名或容器 ID，并将命令中的 `aura-grid` 替换为实际名称。

#### Q2: 提示 `Too many failed attempts. Try again later.`（触发防爆破熔断）？
Aura Grid 内置 Aura Guard 安全防护系统，连续输错密码会被临时锁定 IP。  
**对策**：使用方案一重置新密码后，执行 `docker restart aura-grid` 重启容器即可立刻清空失败计数与熔断锁定。
