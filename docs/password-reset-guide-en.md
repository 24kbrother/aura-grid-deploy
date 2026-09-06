# 🔐 Password Reset & Account Recovery Guide

> Applicable to **Aura Grid LITE (Open-Source Free Edition)** and **PRO Edition**.  
> If you forget your administrator password or need to reset your account credentials, you can perform autonomous recovery within seconds via your host server or NAS terminal.  
> **Data Guarantee: Resetting your credentials will NEVER affect or erase your dashboard layouts, 3D floorplans, or entity bindings.**

---

## 💡 Data Safety Guarantee

Aura Grid enforces strict architectural decoupling between **authentication** and **dashboard configurations**:
- **Administrator Credentials**: Stored exclusively in the database `User` table (username and salted bcrypt hash).
- **Dashboard Layouts & Business Data**: All 3D floorplans, widget card positions, widget states, Home Assistant tokens, and room setups are stored in the separate `ProjectConfig` table.

Therefore, resetting your password or clearing the user table will leave all your carefully designed dashboards completely intact.

---

## 🛠️ Method 1: Instant Reset via Docker Terminal (Recommended · Zero Downtime)

This is the cleanest approach. It updates the password hash inside the running container without requiring a restart.

### Step 1: Check Container Name
The default container name is `aura-grid`. Run the following command on your host machine to verify:
```bash
docker ps --filter "name=aura-grid" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

### Step 2: Retrieve Existing Username (Optional)
If you also forgot the administrator username, execute:
```bash
docker exec -it aura-grid node -e '
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
prisma.user.findMany().then(users => {
  console.log("System Users:", users.map(u => u.username));
}).finally(() => prisma.$disconnect());
'
```

### Step 3: Set New Password
Replace `YourNewPassword123` in the snippet below with your desired password, then run:
```bash
docker exec -it aura-grid node -e '
const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
async function main() {
  const newPassword = "YourNewPassword123"; // 👈 Enter your desired new password here
  
  const hash = await bcrypt.hash(newPassword, 10);
  const user = await prisma.user.findFirst();
  if (user) {
    await prisma.user.update({
      where: { id: user.id },
      data: { password: hash }
    });
    console.log("=========================================");
    console.log("✅ Password reset successfully!");
    console.log("👉 Username:", user.username);
    console.log("👉 New password is live immediately. No restart required!");
    console.log("=========================================");
  } else {
    console.log("⚠️ No user found. Please re-initialize via Method 2.");
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
'
```
You can now log in immediately from your browser with the new password.

---

## 🔄 Method 2: Reset Setup Wizard & Recreate Admin Account (Most Intuitive)

Aura Grid features an automatic self-healing detection: **When the database has 0 users, the frontend automatically redirects to the first-time Setup Wizard (`/setup`)**.

### Step 1: Clear User Table
Run the following command on your host:
```bash
docker exec -it aura-grid node -e '
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
prisma.user.deleteMany().then(r => {
  console.log("=========================================");
  console.log("✅ Administrator status reset (cleared old credentials)");
  console.log("👉 Floorplans, widgets, and layouts are 100% preserved!");
  console.log("👉 Refresh your browser to access the Setup Wizard.");
  console.log("=========================================");
}).finally(() => prisma.$disconnect());
'
```

### Step 2: Complete Setup in Browser
1. Refresh the Aura Grid dashboard in your browser;
2. The initial Setup Wizard (`/setup`) will automatically appear;
3. Enter your desired **new username and new password**;
4. Upon submission, you will be automatically logged in, with all dashboard components preserved.

---

## 🗄️ Method 3: Direct SQLite Modification on Host (Alternative)

If your deployment mounts `./data:/app/prisma/data` and your host has `sqlite3` installed:

```bash
# Navigate to your deployment directory
cd /path/to/aura-grid-deploy

# Delete user records to trigger Setup Wizard
sqlite3 ./data/prod.db "DELETE FROM User;"
```
Refresh the browser afterwards to recreate your account.

---

## 🖥️ NAS & Web Panel Instructions (Synology / QNAP / 1Panel)

### 1. Synology DSM / QNAP Container Station
1. Open **Container Manager** (or Docker);
2. Find the running `aura-grid` container, click **Action / Terminal** -> **Create Terminal**;
3. Select `sh` as the shell;
4. Paste the `node -e '...'` code from Method 1 or 2 directly into the terminal window and hit Enter.

### 2. 1Panel / aaPanel
1. Navigate to **Containers**;
2. Locate `aura-grid` and open the web terminal;
3. Paste and run the `node -e '...'` script.

---

## ❓ FAQ & Troubleshooting

#### Q1: `Error: No such container: aura-grid`?
Ensure the container name matches. Run `docker ps` to verify your actual container name or ID.

#### Q2: `Too many failed attempts. Try again later.`?
This is triggered by the Aura Guard anti-brute-force mechanism. After resetting your password with Method 1, run `docker restart aura-grid` to instantly reset the rate-limiter counters.
