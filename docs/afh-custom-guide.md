# Aura Floating Hub (AFH) 浮动图层微件配置与开发指南

本指南旨在指导开发人员与 AI 助手为 Aura Grid Pro 的 “Aura Floating Hub (AFH) 浮动图层系统” 编写自定义 HTML 微件。通过本指南，可以确保自定义浮动组件与图层的拖拽定位、预置视觉主题完美贴合，并实现高效的 Home Assistant 双向通信。

---

## 1. 浮动图层运行时特性

AFH 是大屏画布之上的绝对定位悬浮控制层。相较于侧边栏微件，浮动微件在定位、尺寸和主题包裹上具有以下特有的运行时行为：

*   **中心锚定与百分比定位**：浮动微件在画布中采用百分比定位 `left: xPct%` 与 `top: yPct%`。微件的定位锚点位于其几何中心（CSS 样式为 `transform: translate(-50%, -50%)`）。
*   **拖拽交互与状态持久化**：当控制台处于“解锁”状态时，微件上方会覆盖透明拖拽手柄层，此时任何拖拽动作都会实时计算百分比坐标并保存至 `uiStore`。当处于“锁定”状态时，拖拽层消失，微件内自定义的按钮点击与交互事件被完全激活。
*   **外层主题包裹（Theme Wrapper）**：微件在后台可以选配系统内置的磨砂玻璃或霓虹微光主题（如 `afh-theme-glass`、`afh-theme-neon-blue` 等）。选配主题后，外层容器会自动提供圆角、边框阴影以及高斯模糊背景。自定义 HTML 组件将渲染于无内边距（`padding: 0`）的内部容器中，实现像素级的严丝合缝。

---

## 2. 接口与上下文变量

自定义浮动微件使用与侧边栏微件完全一致的动态单文件组件（SFC）渲染引擎，并自动注入以下上下文接口：

### 2.1 `haStore` (Home Assistant 数据仓库)
这是 Pinia 状态仓库，实时维护大屏与 Home Assistant 的所有实体状态。
*   **`haStore.entities`**：核心状态树，类型为 `Record<string, HaEntity>`。
    *   *调用路径*：`haStore.entities['light.living_room']?.state` (常见返回值为 `'on'`, `'off'`, `'unavailable'` 等)。
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
    // 打开灯并设置亮度为 60%
    haStore.callService('light', 'turn_on', 'light.living_room', { brightness: 153 });
    ```

---

## 3. 代码格式规范

```html
<template>
  <div class="afh-custom-widget">
    <!-- HTML 模板：建议容器宽度与高度设置为 100% 以填充外层主题包裹 -->
    <div class="content">
      <span class="status-dot" :class="haStore.connected ? 'is-online' : 'is-offline'"></span>
      <span class="val">{{ haStore.entities['sensor.outdoor_temp']?.state }}°C</span>
    </div>
  </div>
</template>

<script>
// 脚本段：需遵循 export default { setup() { ... } } 规范
// 提示：运行时已对 Vue 核心方法进行了打包代理，请使用 require('vue') 导入所需 API
const { ref, computed, onMounted } = require('vue');

export default {
  setup() {
    onMounted(() => {
      console.log('AFH custom widget ready.');
    });

    return {};
  }
}
</script>

<style>
/* 样式表：挂载时会自动隔离注入，卸载时清除 */
.afh-custom-widget {
  width: 100%;
  height: 100%;
  padding: 12px;
  box-sizing: border-box;
}
.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.is-online { background: #22d3ee; }
.is-offline { background: #f43f5e; }
</style>
```

> [!IMPORTANT]
> **规范限制：**
> 1. **禁止使用 ES Module 静态导入**：在 `<script>` 中不能写 `import { ref } from 'vue'`，因为动态沙箱环境不支持原生 import 解析。必须使用 `const { ref } = require('vue')`。
> 2. **安全性链式访问**：在模板中引用实体状态时，由于系统初始化或链路断开重连期间实体可能短暂为空，**必须**使用 `haStore.entities['xxx']?.state` 的形式，避免抛出底层类型错误。
> 3. **自适应尺寸填充**：由于悬浮微件的物理尺寸（`width` 和 `height`）通常由后台配置面板直接控制，建议将自定义 HTML 容器的 `width` 与 `height` 设置为 `100%`，以完美贴合外部配置尺寸。

---

## 4. 针对 AI 助手的 Prompt 配置指南

在利用外部 AI 助手生成本悬浮微件代码时，可直接将下方 Prompt 复制并发送给 AI，以确保输出的代码能够直接运行且不包含语法兼容问题：

````markdown
请扮演 Vue 3 动态组件与 Home Assistant 系统开发专家，为 Aura Grid Pro 的悬浮图层系统（Aura Floating Hub）开发自定义 HTML 微件代码。

### 运行时上下文与 API 规范
1. 模板与脚本上下文已自动注入全局变量 `haStore`（底层 Pinia 状态仓库）和快捷控制函数 `toggleEntity(entityId)`。
2. 实体状态存储在 `haStore.entities['entity_id']` 中，其数据结构为：
   { entity_id: string, state: string, attributes: { friendly_name: string, [key: string]: any } }
3. 如果需要导入 Vue 核心 API（如 ref, computed, watch, onMounted 等），你必须使用 CommonJS 的 require 语法：
   `const { ref, computed, onMounted } = require('vue');`
   禁止使用 ES Module 的 `import` 语句。
4. 提供可选的 `haStore.callService(domain, service, entity_id, service_data)` 进行复杂服务调用。
5. 模板中读取实体状态必须使用可选链操作符，例如：`haStore.entities['light.bedroom']?.state`。

### 悬浮布局视觉建议
- 微件的最外层 div 必须设置 `w-full h-full` 以适应配置的悬浮尺寸。
- 该微件会被系统预置的主题背景包裹（主题已处理高斯模糊与边框），因此微件内部不需要重复定义磨砂背景与粗边框，只需保持内容居中与排版紧凑。
- 文字排版采用现代无衬线字体，字号字距需精细美观，支持利用过渡实现悬停时的微幅缩放。

### 任务要求
请根据下方描述的需求，输出完整组件代码，只输出代码块，无需输出其他额外说明：
【功能需求】：[在此处填写具体的微件需求，例如：极简气象微悬浮球，显示室外温度与湿度，同时显示天气状况图标。]
````

---

## 5. 参考微件模版

### 模版 A：气象微悬浮球 (Floating Weather Bubble)
*   **推荐尺寸**：120px x 48px
*   **后台主题**：推荐选择 `afh-theme-glass` 或 `afh-theme-neon-blue`
*   **功能**：在极小的高度内，紧凑地横向呈现温度和湿度数据，并带有一条微缩进度条指示空气质量。

```html
<template>
  <div class="weather-bubble flex items-center justify-between w-full h-full px-3 py-1.5 font-sans select-none">
    <!-- Temp Box -->
    <div class="flex flex-col">
      <span class="label">TEMP</span>
      <span class="value">{{ haStore.entities['sensor.outdoor_temperature']?.state || '22.0' }}°C</span>
    </div>
    
    <!-- Divider -->
    <div class="h-6 w-[1px] bg-white/10 mx-1"></div>

    <!-- Humidity Box -->
    <div class="flex flex-col text-right">
      <span class="label">HUMI</span>
      <span class="value">{{ haStore.entities['sensor.outdoor_humidity']?.state || '54' }}%</span>
    </div>
  </div>
</template>

<style>
.weather-bubble {
  height: 100%;
  width: 100%;
}
.weather-bubble .label {
  font-size: 8px;
  font-weight: 800;
  color: rgba(255, 255, 255, 0.35);
  letter-spacing: 0.1em;
  line-height: 1;
  margin-bottom: 2px;
}
.weather-bubble .value {
  font-size: 13px;
  font-weight: 700;
  color: #ffffff;
  line-height: 1;
}
</style>
```

### 模版 B：全屋灯具监控与一键全关面板 (Floating Light Deck)
*   **推荐尺寸**：180px x 64px
*   **后台主题**：推荐选择 `afh-theme-cyber-red`（灯亮时红光警报）或 `afh-theme-glass`
*   **功能**：动态扫描全屋所有处于开启状态的 `light` 实体并进行数量求和，展示正在开启的灯具数量，并提供一键关闭所有灯具的安全开关。

```html
<template>
  <div class="light-deck flex items-center justify-between w-full h-full px-3.5 font-sans select-none">
    <div class="flex flex-col">
      <span class="title">LIGHT MONITOR</span>
      <div class="flex items-baseline gap-1 mt-0.5">
        <span class="count" :class="activeLightsCount > 0 ? 'text-amber-400' : 'text-gray-400'">{{ activeLightsCount }}</span>
        <span class="unit">盏已点亮</span>
      </div>
    </div>

    <!-- Quick Action Button -->
    <button 
      v-if="activeLightsCount > 0"
      @click="turnOffAllLights"
      class="shutdown-btn flex items-center justify-center rounded-lg border border-red-500/30 bg-red-500/10 px-2.5 py-1.5 transition-all duration-300 hover:bg-red-500/20 hover:scale-105 active:scale-95"
    >
      <span class="btn-text">一键全关</span>
    </button>
  </div>
</template>

<script>
const { computed } = require('vue');

export default {
  setup() {
    // 动态统计所有处于开启状态的灯具数量
    const activeLightsCount = computed(() => {
      let count = 0;
      const entities = haStore.entities;
      for (const id in entities) {
        if (id.startsWith('light.') && entities[id]?.state === 'on') {
          count++;
        }
      }
      return count;
    });

    // 一键全关逻辑
    const turnOffAllLights = () => {
      // 遍历所有打开的灯并依次调用 turn_off 服务
      const entities = haStore.entities;
      for (const id in entities) {
        if (id.startsWith('light.') && entities[id]?.state === 'on') {
          haStore.callService('light', 'turn_off', id).catch(console.error);
        }
      }
    };

    return {
      activeLightsCount,
      turnOffAllLights
    };
  }
}
</script>

<style>
.light-deck {
  height: 100%;
  width: 100%;
}
.light-deck .title {
  font-size: 8px;
  font-weight: 800;
  color: rgba(255, 255, 255, 0.4);
  letter-spacing: 0.08em;
  line-height: 1;
}
.light-deck .count {
  font-size: 20px;
  font-weight: 900;
  line-height: 1;
  transition: color 0.3s;
}
.light-deck .unit {
  font-size: 9px;
  color: rgba(255, 255, 255, 0.4);
  font-weight: 600;
}
.light-deck .shutdown-btn {
  cursor: pointer;
  outline: none;
}
.light-deck .btn-text {
  font-size: 10px;
  font-weight: 700;
  color: #f43f5e;
}
</style>
```
