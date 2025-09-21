# Frontend Documentation - ResizableVideo Component

## 概述 (Overview)

为 Telegram Copilot Bot 添加了一个完整的 React 前端界面，核心是 `ResizableVideo` 组件，支持视频窗口的拖拽和缩放功能。

A complete React frontend interface has been added to the Telegram Copilot Bot, featuring the `ResizableVideo` component with drag and resize functionality for video windows.

## 功能特性 (Features)

### ResizableVideo 组件
- ✨ **鼠标拖拽移动**: 点击视频窗口任意位置拖拽移动
- 🔄 **八方向缩放**: 提供八个缩放控制点（四个角 + 四个边）
- 📐 **尺寸限制**: 可配置最小/最大宽度和高度
- 🎯 **边界检测**: 自动约束在浏览器窗口范围内
- 🎮 **原生控制器**: 保持视频原生播放控制功能
- 💫 **流畅动画**: 优化的 CSS 过渡效果和视觉反馈

### 主界面功能
- 🎬 **示例视频**: 预设三个测试视频选项
- 🔗 **自定义URL**: 支持加载任意视频URL
- 📱 **响应式设计**: 适配不同屏幕尺寸
- 🎨 **现代UI**: 渐变背景和毛玻璃效果

## 文件结构 (File Structure)

```
telegram-copilot-bot/
├── src/                           # React 源代码
│   ├── components/
│   │   ├── ResizableVideo.jsx     # 核心组件
│   │   └── ResizableVideo.css     # 组件样式
│   ├── App.jsx                    # 主应用组件
│   ├── App.css                    # 应用样式
│   ├── index.js                   # 入口文件
│   └── index.html                 # HTML 模板
├── dist/                          # 构建输出 (生产版本)
├── package.json                   # 依赖配置
├── webpack.config.js              # 构建配置
└── bot.py                         # 集成的 Python 服务器
```

## 技术栈 (Tech Stack)

### 前端
- **React 18**: 主要框架
- **Webpack 5**: 打包构建
- **Babel**: JavaScript 转译
- **CSS3**: 样式和动画

### 后端集成
- **aiohttp**: Python Web 服务器
- **静态文件服务**: 提供前端资源

## 安装和运行 (Installation & Usage)

### 1. 安装依赖
```bash
npm install
```

### 2. 开发模式
```bash
npm run dev
# 访问 http://localhost:3000
```

### 3. 生产构建
```bash
npm run build
# 生成 dist/ 目录
```

### 4. 与 Bot 集成运行
```bash
python bot.py
# 访问 http://localhost:8080/app
```

## API 参考 (API Reference)

### ResizableVideo Props

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `src` | string | - | 视频源URL |
| `initialWidth` | number | 400 | 初始宽度(px) |
| `initialHeight` | number | 300 | 初始高度(px) |
| `minWidth` | number | 200 | 最小宽度(px) |
| `minHeight` | number | 150 | 最小高度(px) |
| `maxWidth` | number | 800 | 最大宽度(px) |
| `maxHeight` | number | 600 | 最大高度(px) |

### 使用示例
```jsx
<ResizableVideo
  src="https://example.com/video.mp4"
  initialWidth={500}
  initialHeight={300}
  minWidth={250}
  minHeight={150}
  maxWidth={800}
  maxHeight={600}
/>
```

## 组件实现细节 (Implementation Details)

### 拖拽机制
- 使用 `onMouseDown`, `onMouseMove`, `onMouseUp` 事件
- 全局事件监听确保跨元素拖拽
- 自动边界检测和位置约束

### 缩放实现
- 八个缩放控制点，支持各方向缩放
- 实时尺寸计算和位置调整
- 保持宽高比选项（可扩展）

### 性能优化
- 使用 `useCallback` 优化事件处理
- CSS `transform` 提高渲染性能
- 合理的重新渲染控制

## 浏览器兼容性 (Browser Compatibility)

- ✅ Chrome 60+
- ✅ Firefox 55+
- ✅ Safari 12+
- ✅ Edge 79+

## 开发指南 (Development Guide)

### 添加新功能
1. 在 `ResizableVideo.jsx` 中添加新的 props
2. 更新状态管理逻辑
3. 添加相应的 CSS 样式
4. 更新文档

### 样式定制
修改 `ResizableVideo.css` 中的变量：
```css
:root {
  --resize-handle-color: #007bff;
  --border-color: #007bff;
  --shadow-color: rgba(0, 123, 255, 0.3);
}
```

### 调试技巧
- 使用 React DevTools 检查组件状态
- 在浏览器控制台查看事件日志
- 使用 `console.log` 跟踪鼠标事件

## 未来改进 (Future Enhancements)

- [ ] 添加宽高比锁定选项
- [ ] 支持多视频窗口
- [ ] 添加窗口吸附功能
- [ ] 视频缩略图预览
- [ ] 键盘快捷键支持
- [ ] 触摸设备支持优化

## 许可证 (License)

MIT License - 与主项目保持一致