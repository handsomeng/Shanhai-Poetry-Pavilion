# 山海诗馆 - 设计系统规范

> 基于 Lovart 生成的设计系统，融合宋代美学留白意境与当代瑞士平面设计的理性克制。

## 设计原则

### Less is More
删除一切非必要装饰，让内容自己说话。

### 呼吸空间
每个元素周围都有大量留白，内容占比不超过 40%。

### 墨色美学
只用黑白灰，拒绝彩色，如同水墨画般纯粹。

### 纸本触感
如同在宣纸上排版，追求古典与现代的平衡。

### 意境优先
留白本身就是设计语言，空白传递诗意。

---

## 色彩系统

### 主色调
```
主背景：#FFFFFF（纯白，象征宣纸）
```

### 文字色阶
```
主文本：  #0A0A0A（深邃墨黑）
次级文本：#4A4A4A（中灰）
辅助文本：#ABABAB（浅灰）
四级文字：#D4D4D4（极浅灰）
```

### 强调色
```
强调色：  #1A1A1A（纯黑）
次强调色：#4A4A4A（中灰）
```

### 边框与分割
```
分割线/边框：#E5E5E5（1pt 细线）
卡片背景：  #FBFBFB（几乎白色）
```

### 状态色
```
错误：#D32F2F
成功：#388E3C
```

---

## 字体系统

### 一级标题
- **字体**：宋体/衬线（Serif）
- **字重**：极细（UltraLight）
- **字号**：72-96pt
- **用途**：App 主标题、重要页面标题

### 二级标题
- **字体**：宋体/衬线（Serif）
- **字重**：极细（UltraLight）
- **字号**：48-64pt
- **用途**：页面标题、章节标题

### 诗歌内容
- **字体**：宋体/衬线（Serif）
- **字重**：Light
- **字号**：20-24pt
- **用途**：诗歌正文显示

### 正文
- **字体**：宋体/衬线（Serif）
- **字重**：Light
- **字号**：16-20pt
- **用途**：常规文本、描述性内容

### 辅助文字
- **字体**：无衬线（Sans Serif）
- **字重**：极轻（UltraLight）
- **字号**：12-14pt
- **用途**：标签、说明文字、元数据

---

## 空间规范

### 布局原则
- **内容区占比**：≤ 40%
- **留白占比**：≥ 60%
- **外边距**：64-96pt
- **区块间距**：40-160pt

### 间距层级
```swift
xs:    8pt   // 最小间距
sm:    16pt  // 小间距
md:    24pt  // 中等间距
lg:    40pt  // 大间距
xl:    64pt  // 超大间距
xxl:   96pt  // 巨大间距
xxxl:  128pt // 超级巨大
huge:  160pt // 震撼级留白
```

---

## UI 组件规范

### 按钮
- **高度**：48pt
- **内边距**：左右 32pt
- **边框**：1pt 细线或纯黑填充
- **圆角**：4-8pt 或直角
- **字体**：正文 Light 16-18pt
- **状态**：
  - 普通态：白底黑字，1pt 黑色边框
  - 强调态：黑底白字，无边框
  - 禁用态：浅灰背景，浅灰文字

### 输入框
- **高度**：40-48pt
- **样式**：下划线风格（仅底部有线）
- **边框**：1pt 细线
- **内边距**：垂直 16-24pt
- **字体**：正文 Light 16-18pt
- **placeholder**：辅助文本色 #ABABAB

### 卡片
- **内边距**：32-40pt
- **边框**：1pt 细线 #E5E5E5
- **圆角**：4-8pt
- **背景**：纯白 #FFFFFF 或极浅灰 #FBFBFB
- **阴影**：无（保持扁平化）

### 图标
- **尺寸**：24×24px（小）/ 32×32px（大）
- **风格**：线性图标
- **描边**：1px
- **颜色**：主文本色或次级文本色

### 分割线
- **粗细**：1pt
- **颜色**：#E5E5E5
- **间距**：上下各 40pt 以上

---

## 圆角规范

```
small:  4pt   // 小元素
medium: 6pt   // 中等元素
large:  8pt   // 大元素
card:   4pt   // 卡片（可用直角 0pt 更现代）
```

---

## 实现指南

### SwiftUI 代码示例

#### 使用设计系统的颜色
```swift
Text("山海诗馆")
    .foregroundColor(Colors.textInk)
    .background(Colors.backgroundCream)
```

#### 使用设计系统的字体
```swift
Text("一级标题")
    .font(Fonts.h1())
    
Text("诗歌内容")
    .font(Fonts.bodyPoem())
```

#### 使用设计系统的间距
```swift
VStack(spacing: Spacing.xl) {
    // 内容
}
.padding(.horizontal, Spacing.xxl)
```

#### 标准按钮样式
```swift
Button("开始创作") {
    // 动作
}
.font(Fonts.body())
.frame(maxWidth: .infinity)
.frame(height: ComponentSize.buttonHeight)
.padding(.horizontal, ComponentSize.buttonPaddingHorizontal)
.foregroundColor(.white)
.background(Colors.accentTeal)
.cornerRadius(CornerRadius.medium)
```

#### 标准输入框样式
```swift
TextField("", text: $text, prompt: Text("提示文字").foregroundColor(Colors.textTertiary))
    .font(Fonts.body())
    .foregroundColor(Colors.textInk)
    .frame(height: ComponentSize.inputHeight)
    .overlay(
        Rectangle()
            .frame(height: ComponentSize.inputBorderWidth)
            .foregroundColor(Colors.border)
        , alignment: .bottom
    )
```

#### 标准卡片样式
```swift
VStack(alignment: .leading, spacing: Spacing.md) {
    // 卡片内容
}
.padding(ComponentSize.cardPadding)
.background(Colors.cardBackground)
.cornerRadius(CornerRadius.card)
.overlay(
    RoundedRectangle(cornerRadius: CornerRadius.card)
        .stroke(Colors.border, lineWidth: ComponentSize.cardBorderWidth)
)
```

---

## 设计参考

### 品牌参考
- **Muji**：极简主义，删除非必要元素
- **Apple**：优雅的留白与克制的设计
- **The New York Times**：经典的文字排版

### 设计师参考
- **Dieter Rams**：少即是多的设计哲学
- **Kenya Hara / 原研哉**：日式美学与留白艺术

### 风格关键词
- Wabi-Sabi 侘寂美学
- 瑞士极简主义
- 宋代山水画留白
- 日式禅意
- 当代衬线字体排版

### Dribbble 搜索关键词
```
minimalist poetry app
monochrome design system
zen interface
Chinese typography modern
editorial design system
```

---

## 设计资产

### 文件位置
- **设计规范图片**：`/BetweenLines/DesignAssets/`
- **代码实现**：`/BetweenLines/Utilities/Constants.swift`
- **本文档**：`/BetweenLines/DESIGN_SYSTEM.md`

### 更新日志
- **2024.10.22**：基于 Lovart 生成的设计系统创建初版规范
- **2024.10.22**：优化手机端显示效果，调整字体粗细和间距

---

## 注意事项

1. **字体在真机显示**：ultraLight 字重在小屏幕可能过细模糊，根据实际效果调整为 thin 或 light
2. **留白在小屏幕**：手机端留白可适当压缩（60-80%），但保持呼吸感
3. **触控热区**：所有可点击元素最小热区 44×44pt（iOS 规范）
4. **无障碍**：确保文字与背景对比度符合 WCAG AA 标准（4.5:1）
5. **一致性**：所有页面严格遵循设计系统，不随意创建新样式

---

**山海诗馆 Design System v1.0**  
*精选古诗，编古诗*  
*Less is More，意境优先*

