# Aura Grid Pro 自定义微件开发与配置指南

本指南供开发人员及 AI 助手（如 Claude、GPT 等）参考，用于编写 Aura Grid Pro 侧边栏“混合滑动模块”的自定义渲染代码。通过遵循本指南的接口与格式规范，可以确保编写的微件在沙箱容器内稳定运行，并实现与 Home Assistant 的实时双向数据交互。

---

## 1. 运行时架构说明

Aura Grid Pro 内置了一套轻量级的动态单文件组件（SFC）解析与编译引擎。当用户在后台输入 HTML、CSS 与 JavaScript 混合文本后，系统会在浏览器端动态执行以下编译与隔离工作：

*   **样式局部化隔离**：`<style>` 标签内的 CSS 样式在组件挂载时动态注入到页面的 `<head>` 中，并在组件销毁（如切页或关闭侧边栏）时自动移出，避免对大屏全局样式造成污染。
*   **异常捕获与容错**：组件运行时使用 `onErrorCaptured` 拦截子树内的所有渲染与逻辑错误。如果微件内部代码存在格式错误或运行时异常，错误信息仅会局部呈现在该微件容器内，不会引发大屏其他区域的级联崩溃或闪退。
*   **实时编译**：保存代码后，渲染引擎会立即重新编译并热重载组件，无需刷新整个大屏页面。

---

## 2. 接口与上下文变量

自定义微件在渲染时已自动注入了与 Home Assistant 交互的上下文接口。微件的模板（Template）与脚本（Script）均可直接调用以下变量和方法：

### 2.1 `haStore` (Home Assistant 数据仓库)
这是 Pinia 状态仓库，实时维护大屏与 Home Assistant 的所有实体状态。
*   **`haStore.entities`**：核心状态树，类型为 `Record<string, HaEntity>`。
    *   *获取实体状态*：`haStore.entities['light.living_room']?.state` (常见返回值为 `'on'`, `'off'`, `'unavailable'` 等)。
    *   *获取属性*：`haStore.entities['sensor.temperature']?.attributes.friendly_name` 或获取其他自定义属性如温度 `current_temperature`、亮度 `brightness` 等。
*   **`haStore.connected`** (Boolean)：HA WebSocket 的链路连接状态。
*   **`haStore.loading`** (Boolean)：首屏实体数据是否处于加载状态。
*   **`haStore.friendlyNamesMap`** (Computed Map)：友好中文名称至实体对象的映射表。

### 2.2 `toggleEntity(entityId)`
内置的便捷控制函数，用于快速反转开关、灯具、插座等类型实体的开/关状态，无需手动解析 Domain 或调用底层方法。
*   *调用示例*：`toggleEntity('light.living_room_light')`

### 2.3 `haStore.callService(...)`
如果需要更复杂的交互控制（例如设定空调温度、调节灯光亮度或颜色），可直接通过此方法发起底层服务调用：
*   *参数规范*：`haStore.callService(domain, service, entity_id, service_data)`
    *   `domain` (String): 服务领域，例如 `'light'`, `'climate'`, `'media_player'`
    *   `service` (String): 具体动作，例如 `'turn_on'`, `'set_temperature'`, `'volume_up'`
    *   `entity_id` (String): 实体 ID
    *   `service_data` (Object): 附加的参数配置，例如 `{ brightness: 153 }`
*   *调用示例*：
    ```javascript
    // 打开灯具并将亮度设定为 60% (153/255)
    haStore.callService('light', 'turn_on', 'light.living_room', { brightness: 153 });
    ```

---

## 3. 代码格式规范 (SFC 标准)

微件的代码应遵循标准的 Mini-SFC 单文件组件规范，结构如下：

```html
<template>
  <div class="custom-widget-container">
    <!-- HTML 模板：支持 Vue 3 模板指令如 v-if, v-for, @click -->
    <p>当前客厅温度：{{ haStore.entities['sensor.livingroom_temp']?.state }} °C</p>
    <button @click="toggleEntity('light.living_room')">切换客厅灯</button>
  </div>
</template>

<script>
// 脚本段：需遵循 export default { setup() { ... } } 规范
// 提示：运行时已对 Vue 核心方法进行了打包代理，请使用 require('vue') 导入所需 API
const { ref, computed, onMounted } = require('vue');

export default {
  setup() {
    const isReady = ref(true);
    
    onMounted(() => {
      console.log('Custom widget mounted.');
    });

    // 必须将模板中需要访问的变量或函数 return 暴露出去
    return {
      isReady
    };
  }
}
</script>

<style>
/* 样式表：挂载时会自动隔离注入，卸载时清除 */
.custom-widget-container {
  padding: 16px;
  background: rgba(20, 26, 35, 0.6);
  border-radius: 24px;
  backdrop-filter: blur(12px);
}
</style>
```

> [!IMPORTANT]
> **规范限制：**
> 1. **禁止使用 ES Module 静态导入**：在 `<script>` 中不能写 `import { ref } from 'vue'`，因为动态沙箱环境不支持原生 import 解析。必须使用 `const { ref } = require('vue')`。
> 2. **安全性链式访问**：在模板中引用实体状态时，由于系统初始化或链路断开重连期间实体可能短暂为空，**必须**使用 `haStore.entities['xxx']?.state` 的形式，避免抛出底层类型错误。
> 3. **无脚本模式**：如果微件仅涉及简单的状态显示与点击操作，可省略整个 `<script>` 标签，直接在模板中调用 `haStore` 和 `toggleEntity`。

---

## 4. 视觉与排版设计建议

为了保持自定义微件与 Aura Grid Pro 原生系统的磨砂玻璃及极简科技风视觉体系的一致性，设计代码时建议参考以下建议：

*   **背景色与质感**：背景推荐使用暗色实色 `#141a23` 或高透明度的暗色磨砂质感 `rgba(20, 26, 35, 0.65)`，配合 `backdrop-filter: blur(12px)`。
*   **边框与阴影**：推荐使用极细边框 `border border-white/10`，悬停或激活状态下可配合柔和的微光投影 `box-shadow: 0 0 15px rgba(59, 130, 246, 0.15)`。
*   **文字排版**：标题文本推荐使用渐变色（如 `bg-gradient-to-r from-blue-400 to-indigo-400 bg-clip-text text-transparent`），副标题或标签建议使用微缩大写字距以增强科技质感（`tracking-widest text-[9px] uppercase text-gray-500`）。
*   **动画开销优化**：严禁在自定义微件中编写大面积的高斯模糊位移、高频缩放等极度消耗 GPU 算力的动画。建议使用 `transition-all duration-300 ease-out` 挂载平滑的位移或缩放过渡。

---

## 5. 面向 AI 助手的 Prompt 配置指南

在利用外部 AI 助手（如 Claude、GPT）生成本微件代码时，可直接将下方 Prompt 复制并发送给 AI，以确保输出的代码能够直接运行且不包含语法兼容问题：

````markdown
请扮演 Vue 3 动态组件与 Home Assistant 系统开发专家，为 Aura Grid Pro 侧边栏的自定义微件编写一段包含 <template>、<script> 与 <style> 的单文件组件代码。

### 运行时上下文与 API 规范
1. 模板与脚本上下文已自动注入全局变量 `haStore`（底层 Pinia 状态仓库）和快捷控制函数 `toggleEntity(entityId)`。
2. 实体状态存储在 `haStore.entities['entity_id']` 中，其数据结构为：
   { entity_id: string, state: string, attributes: { friendly_name: string, [key: string]: any } }
3. 如果需要导入 Vue 核心 API（如 ref, computed, watch, onMounted 等），你必须使用 CommonJS 的 require 语法：
   `const { ref, computed, onMounted } = require('vue');`
   禁止使用 ES Module 的 `import` 语句。
4. 提供可选的 `haStore.callService(domain, service, entity_id, service_data)` 进行复杂服务调用。
5. 模板中读取实体状态必须使用可选链操作符，例如：`haStore.entities['light.bedroom']?.state`。

### 视觉规范
- 背景使用 `#141a23` 或 `rgba(20, 26, 35, 0.65)`，圆角配置为 `rounded-[1.5rem]`，配合 `border border-white/10` 的薄边框。
- 交互卡片或按钮悬停时，应用平滑过渡效果（`hover:border-blue-500/30 hover:shadow-[0_0_15px_rgba(59,130,246,0.15)] transition-all duration-300`）。
- 文字排版采用现代无衬线字体，字号字距需精细美观。

### 任务要求
请根据下方描述的需求，输出完整组件代码，只输出代码块，无需输出其他额外说明：
【功能需求】：[在此处填写具体的微件需求，例如：客厅核心设备控制面板，展示客厅主灯、风扇状态并支持点击控制，同时显示温度与PM2.5数值。]
````

---

## 6. 参考微件模版

以下提供两个经过测试的自定义组件模版，可直接复制到配置框中使用。

### 模版 A：客厅核心控制面板 (Lounge Control Panel)
*   **功能**：展示并控制客厅灯光与风扇的开合状态，提供环境数据的实时展示及相应的激活态微光指示。

```html
<template>
  <div class="lounge-panel flex flex-col h-full justify-between p-4 font-sans select-none">
    <!-- Header -->
    <div class="flex items-center justify-between border-b border-white/10 pb-2">
      <div class="flex items-center gap-2">
        <span class="w-2 h-2 rounded-full bg-cyan-400"></span>
        <span class="text-[11px] font-extrabold tracking-widest text-cyan-400 uppercase">Lounge Panel</span>
      </div>
      <span class="text-[9px] text-gray-500 bg-white/5 border border-white/10 px-2 py-0.5 rounded-full">CORE CONTROL</span>
    </div>

    <!-- Stats Display -->
    <div class="grid grid-cols-2 gap-2 my-3">
      <div class="bg-white/5 border border-white/5 rounded-xl p-2.5 flex flex-col">
        <span class="text-[9px] text-gray-400 tracking-wider">温度</span>
        <span class="text-base font-black text-white mt-0.5">
          {{ haStore.entities['sensor.livingroom_temperature']?.state || '24.5' }}<span class="text-xs font-normal text-cyan-400 ml-0.5">°C</span>
        </span>
      </div>
      <div class="bg-white/5 border border-white/5 rounded-xl p-2.5 flex flex-col">
        <span class="text-[9px] text-gray-400 tracking-wider">PM2.5</span>
        <span class="text-base font-black text-white mt-0.5">
          {{ haStore.entities['sensor.livingroom_pm25']?.state || '18' }}<span class="text-xs font-normal text-emerald-400 ml-0.5">AQI</span>
        </span>
      </div>
    </div>

    <!-- Quick Action Switches -->
    <div class="flex flex-col gap-2">
      <!-- Device Item 1 -->
      <div 
        @click="toggleEntity('light.living_room_light')"
        class="device-card flex items-center justify-between p-3 rounded-xl border cursor-pointer"
        :class="haStore.entities['light.living_room_light']?.state === 'on' ? 'is-active' : 'is-inactive'"
      >
        <div class="flex flex-col">
          <span class="text-xs font-bold transition-colors duration-300">客厅主灯</span>
          <span class="text-[9px] opacity-60 mt-0.5">{{ haStore.entities['light.living_room_light']?.state === 'on' ? '已开启' : '已关闭' }}</span>
        </div>
        <div class="indicator w-2.5 h-2.5 rounded-full transition-all duration-500"></div>
      </div>

      <!-- Device Item 2 -->
      <div 
        @click="toggleEntity('switch.livingroom_fan')"
        class="device-card flex items-center justify-between p-3 rounded-xl border cursor-pointer"
        :class="haStore.entities['switch.livingroom_fan']?.state === 'on' ? 'is-active' : 'is-inactive'"
      >
        <div class="flex flex-col">
          <span class="text-xs font-bold transition-colors duration-300">循环风扇</span>
          <span class="text-[9px] opacity-60 mt-0.5">{{ haStore.entities['switch.livingroom_fan']?.state === 'on' ? '已开启' : '已关闭' }}</span>
        </div>
        <div class="indicator w-2.5 h-2.5 rounded-full transition-all duration-500"></div>
      </div>
    </div>

    <!-- Footer -->
    <div class="mt-3 flex justify-between items-center text-[9px] text-gray-500">
      <span>Link State: {{ haStore.connected ? 'ONLINE' : 'OFFLINE' }}</span>
      <span>AURA MODULE</span>
    </div>
  </div>
</template>

<style>
.lounge-panel {
  background: #141a23;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 1.5rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.device-card {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.is-active {
  background: rgba(6, 182, 212, 0.08);
  border-color: rgba(6, 182, 212, 0.4);
  color: #22d3ee;
  box-shadow: 0 0 15px rgba(6, 182, 212, 0.1);
}
.is-active .indicator {
  background: #22d3ee;
  box-shadow: 0 0 8px #22d3ee;
}

.is-inactive {
  background: rgba(255, 255, 255, 0.02);
  border-color: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
}
.is-inactive .indicator {
  background: rgba(255, 255, 255, 0.15);
}

.device-card:hover {
  transform: translateY(-2px);
}
</style>
```

### 模版 B：设备低电量预警雷达 (Battery Alert Radar)
*   **功能**：遍历 `haStore.entities` 中的所有实体，自动归纳电量低于或等于 30% 的设备，并按照剩余电量百分比由低到高进行升序展示。

```html
<template>
  <div class="battery-card flex flex-col h-full justify-between p-4 font-sans select-none">
    <!-- Header -->
    <div class="flex items-center justify-between border-b border-rose-500/20 pb-2">
      <div class="flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-rose-500 shadow-[0_0_8px_#f43f5e]"></span>
        <span class="text-[11px] font-extrabold tracking-widest text-rose-500 uppercase">Battery Alert</span>
      </div>
      <span class="text-[9px] text-rose-400 bg-rose-500/10 border border-rose-500/20 px-2 py-0.5 rounded-full uppercase font-bold tracking-wider">
        {{ lowBatteries.length }} Alerts
      </span>
    </div>

    <!-- Battery List -->
    <div class="battery-list flex-1 overflow-y-auto no-scrollbar my-3 gap-2 flex flex-col pr-1">
      <div v-for="item in lowBatteries" :key="item.entity_id" class="battery-item flex items-center justify-between p-2.5 bg-rose-500/5 border border-rose-500/10 rounded-xl hover:border-rose-500/30 transition-all duration-300">
        <div class="flex flex-col min-w-0">
          <span class="text-xs font-bold text-gray-200 truncate">{{ item.name }}</span>
          <span class="text-[9px] text-gray-500 font-mono mt-0.5 truncate">{{ item.entity_id }}</span>
        </div>
        <div class="flex items-center gap-2">
          <!-- Mini Horizontal Gauge -->
          <div class="w-10 h-1.5 bg-white/10 rounded-full overflow-hidden">
            <div class="h-full bg-rose-500 shadow-[0_0_6px_#f43f5e]" :style="{ width: item.level + '%' }"></div>
          </div>
          <span class="text-xs font-black text-rose-400 font-mono">{{ item.level }}%</span>
        </div>
      </div>
      
      <div v-if="lowBatteries.length === 0" class="flex flex-col items-center justify-center py-10 opacity-50">
        <span class="text-[10px] text-emerald-400 font-bold uppercase tracking-widest">System Nominal</span>
        <span class="text-[9px] text-gray-500 mt-1">全屋设备电量充足</span>
      </div>
    </div>

    <!-- Footer -->
    <div class="text-[9px] text-gray-600 flex justify-between items-center">
      <span>Auto Scan Active</span>
      <span>THRESHOLD &lt; 30%</span>
    </div>
  </div>
</template>

<script>
const { computed } = require('vue');

export default {
  setup() {
    const lowBatteries = computed(() => {
      const list = [];
      const entities = haStore.entities;
      
      for (const id in entities) {
        const entity = entities[id];
        let level = null;
        if (entity.attributes && typeof entity.attributes.battery !== 'undefined') {
          level = Number(entity.attributes.battery);
        } else if (entity.attributes && typeof entity.attributes.battery_level !== 'undefined') {
          level = Number(entity.attributes.battery_level);
        } else if (id.endsWith('_battery') && !isNaN(Number(entity.state))) {
          level = Number(entity.state);
        }
        
        if (level !== null && level <= 30 && !isNaN(level)) {
          list.push({
            entity_id: id,
            name: entity.attributes?.friendly_name || id,
            level: level
          });
        }
      }
      
      return list.sort((a, b) => a.level - b.level);
    });

    return {
      lowBatteries
    };
  }
}
</script>

<style>
.battery-card {
  background: #141a23;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 1.5rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  height: 100%;
}

.battery-list {
  max-height: 200px;
}

.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>
```
