# 如何添加"山海"App 图标

## 方法 1：使用在线工具（推荐，最简单）

### 步骤 1：转换 SVG 为 PNG

1. 访问 [SVG to PNG Converter](https://svgtopng.com/) 或 [CloudConvert](https://cloudconvert.com/svg-to-png)
2. 上传 `app-icon.svg` 文件
3. 设置尺寸为 **1024x1024**
4. 下载生成的 `app-icon.png`

### 步骤 2：生成所有尺寸

1. 访问 [AppIcon.co](https://appicon.co/)
2. 上传刚才生成的 `app-icon.png` (1024x1024)
3. 选择 **iOS**
4. 点击 **Generate**
5. 下载生成的 `AppIcon.appiconset.zip`

### 步骤 3：导入到 Xcode

1. 解压 `AppIcon.appiconset.zip`
2. 打开 Xcode 项目 `BetweenLines.xcodeproj`
3. 在左侧导航栏找到 `Assets.xcassets`
4. 点击 `AppIcon`
5. 将解压后的所有 PNG 图片拖入对应的格子中
   - 或者直接替换整个 `AppIcon.appiconset` 文件夹

### 步骤 4：运行项目

1. `Cmd + R` 运行
2. 查看主屏幕，应该能看到"山海"图标了

---

## 方法 2：使用 Figma（适合调整细节）

### 步骤 1：导入 SVG 到 Figma

1. 打开 [Figma](https://www.figma.com/)
2. 新建文件
3. `File → Import` → 选择 `app-icon.svg`

### 步骤 2：调整设计

- 调整字体（推荐：方正宋刻本秀楷、思源宋体）
- 调整字间距
- 调整位置（垂直居中、水平居中）
- 调整字号（建议 240-300px）

### 步骤 3：导出

1. 选中画布（1024x1024）
2. 右侧 Export → PNG → 2x → Export
3. 得到 2048x2048 的图片，缩小到 1024x1024
4. 使用 **方法 1 的步骤 2-4** 继续

---

## 方法 3：命令行快速生成（Mac 用户）

在终端运行以下命令：

```bash
# 1. 安装 ImageMagick（如果没有）
brew install imagemagick librsvg

# 2. 转换 SVG 为 PNG
cd /Users/handsomeng/Downloads/vibe-coding/BetweenLines/BetweenLines
rsvg-convert -w 1024 -h 1024 app-icon.svg -o app-icon-1024.png

# 3. 使用在线工具生成所有尺寸（推荐方法 1 的步骤 2）
# 或者手动生成所有尺寸：
mkdir AppIcon.appiconset
convert app-icon-1024.png -resize 1024x1024 AppIcon.appiconset/icon-1024.png
convert app-icon-1024.png -resize 180x180 AppIcon.appiconset/icon-180.png
convert app-icon-1024.png -resize 120x120 AppIcon.appiconset/icon-120.png
convert app-icon-1024.png -resize 87x87 AppIcon.appiconset/icon-87.png
convert app-icon-1024.png -resize 80x80 AppIcon.appiconset/icon-80.png
convert app-icon-1024.png -resize 60x60 AppIcon.appiconset/icon-60.png
convert app-icon-1024.png -resize 58x58 AppIcon.appiconset/icon-58.png
convert app-icon-1024.png -resize 40x40 AppIcon.appiconset/icon-40.png

echo "图标生成完成！"
```

---

## 调整字体（可选）

如果想要更文艺的字体，在 SVG 中修改 `font-family`：

### 推荐字体：

1. **方正宋刻本秀楷** - 古典优雅
   ```xml
   font-family="FZShuKeBXJW, STKaiti, serif"
   ```

2. **思源宋体** - 现代极简
   ```xml
   font-family="Source Han Serif SC, STSong, serif"
   ```

3. **霞鹜文楷** - 清新文艺
   ```xml
   font-family="LXGW WenKai, STKaiti, serif"
   ```

4. **站酷高端黑** - 现代感强
   ```xml
   font-family="Zcool Kuaile, STHeiti, sans-serif"
   ```

修改后重新执行 **方法 1** 即可。

---

## 最终效果预览

图标会显示：
```
┌──────────────┐
│              │
│              │
│    山  海    │  ← 极细宋体，纯黑色
│              │
│              │
└──────────────┘
   纯白背景
```

简洁、优雅、高级！

---

## 故障排除

### 问题 1：图标不显示

- 删除 App，重新运行
- Clean Build Folder (`Cmd + Shift + K`)
- 重启 Xcode

### 问题 2：字体不够文艺

- 使用 Figma 调整字体
- 尝试上述推荐字体
- 调整字重（font-weight: 100 = 极细）

### 问题 3：字间距太紧

修改 SVG 中的 `letter-spacing` 值：
```xml
letter-spacing="60"  <!-- 增大字间距 -->
```

---

需要帮助？随时问我！🎨

