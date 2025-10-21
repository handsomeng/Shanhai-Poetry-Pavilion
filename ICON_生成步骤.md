# 📱 5 分钟快速生成"山海"图标

## 🚀 超简单 3 步骤

### 第 1 步：在线制作图标（30 秒）

1. **访问** → https://www.canva.com/design/play （或 https://www.figma.com）
2. **创建画布** → 1024 x 1024 px
3. **添加文字**：
   - 输入"山海"
   - 字体选择：**思源宋体** 或 **黑体**（Canva 搜索 "Noto Serif SC" 或 "Source Han Serif"）
   - 字号：**280**
   - 颜色：**纯黑 #0A0A0A**
   - 字间距：拉大一点
   - 位置：居中
4. **背景色**：纯白 #FFFFFF
5. **下载**：PNG 格式，1024x1024

### 第 2 步：生成所有尺寸（1 分钟）

1. **访问** → https://www.appicon.co/ （免费、无需注册）
2. **上传**刚才下载的图片
3. **选择** iOS
4. **点击** Generate
5. **下载** AppIcon.appiconset.zip

### 第 3 步：导入 Xcode（1 分钟）

1. **解压** AppIcon.appiconset.zip
2. **打开** Xcode → BetweenLines.xcodeproj
3. **左侧** Assets.xcassets → AppIcon
4. **拖入**所有图片（或替换整个文件夹）
5. **运行** Cmd + R

---

## 🎨 备选方案：用在线 SVG 编辑器

### 方案 A：直接用 SVG Editor

1. 访问 https://www.svgviewer.dev/
2. 复制粘贴以下代码：

```svg
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#FFFFFF"/>
  <text 
    x="512" 
    y="600" 
    font-family="serif" 
    font-size="300" 
    font-weight="100"
    fill="#0A0A0A" 
    text-anchor="middle"
  >山海</text>
</svg>
```

3. 调整位置（修改 y 值）和字号（修改 font-size）
4. 点击 "Download SVG"
5. 用 https://svgtopng.com/ 转成 PNG（1024x1024）
6. 继续第 2 步

---

## 📌 重点提示

### ✅ 确保字体文艺
- Canva 推荐字体：
  - Noto Serif SC（思源宋体）
  - Noto Sans SC（思源黑体）
  - Ma Shan Zheng（清新手写体）
  
### ✅ 确保居中对齐
- 水平居中
- 垂直居中（略偏上更好看）

### ✅ 确保颜色正确
- 背景：纯白 #FFFFFF
- 文字：深黑 #0A0A0A

---

## 🎯 最终效果

```
┌─────────────────┐
│                 │
│                 │
│     山  海      │  ← 极简宋体
│                 │
│                 │
└─────────────────┘
```

**简洁、优雅、高级！**

---

## 💡 如果不想自己做

你也可以：
1. 发给设计师朋友
2. 在 Fiverr 上花 $5-10 找人做
3. 先用系统默认图标，以后再换

---

需要帮助随时问我！我已经创建了 `app-icon.svg`，你可以直接用！🎨

