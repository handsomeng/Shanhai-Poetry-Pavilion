# Lovart 设计系统原稿

> 本文档记录了使用 Lovart 生成的设计系统原始规范和提示词

## 提示词（用于 Lovart）

```
# 山海诗馆 - 设计系统提示词

## 整体风格定位
为一款中国古典诗歌创作 App 设计现代极简风格的设计系统。融合宋代美学的留白意境与当代瑞士平面设计的理性克制，呈现"古意新解"的高级感。

## 色彩系统
- 主背景：纯白 (#FFFFFF)，象征宣纸的纯净
- 文字层级：
  - 主标题：墨黑 (#0A0A0A)，如浓墨
  - 正文：深灰 (#6B6B6B)，如淡墨
  - 辅助文字：浅灰 (#ABABAB)，如水墨渲染
  - 点缀：极淡灰 (#D4D4D4)，如烟雾
- 强调色：纯黑 (#1A1A1A)，极简克制
- 边框/分割线：几乎不可见的淡灰 (#E8E8E8)

避免任何鲜艳色彩，保持黑白灰系的纯粹性。

## 字体系统
- 标题：宋体/衬线字体，字重极细（Thin/UltraLight），大字号（36-48pt）
- 正文：宋体，轻盈字重（Light），适中字号（15-18pt）
- 辅助：无衬线，极轻字重（UltraLight），小字号（10-12pt）
- 字间距：放大 2-4pt，营造呼吸感
- 行间距：1.8-2.0 倍，留出充足空白

## 空间与布局
- 留白比例：内容占比不超过 40%，其余为留白
- 边距：超大（64-96pt），让内容"浮"在空白中
- 元素间距：巨大（40-160pt），制造视觉停顿
- 布局：中轴对称或偏心式不对称，避免拥挤
- 卡片：无圆角（0pt）或极小圆角（4pt），边框极细（0.5pt）

## 视觉元素
- 图标：线性图标，极细线条（1pt），SF Symbols 风格
- 分割线：0.3-0.5pt，颜色几乎透明
- 按钮：极简边框或纯色填充，无阴影，无渐变
- 输入框：仅底部细线，无边框包围
- 卡片：纯白背景或极浅灰（#FBFBFB），无阴影

## 设计参考
- 品牌：Muji、Apple、The New York Times（文字排版）
- 设计师：Dieter Rams、Kenya Hara、原研哉
- 风格关键词：Wabi-Sabi 侘寂美学、瑞士极简主义、宋代山水画留白、日式禅意
- Dribbble 参考：搜索 "minimalist poetry app"、"monochrome design system"、"zen interface"

## 核心设计原则
1. **Less is More**：删除一切非必要装饰
2. **呼吸空间**：每个元素周围都有大量留白
3. **墨色美学**：只用黑白灰，拒绝彩色
4. **纸本触感**：如同在宣纸上排版
5. **意境优先**：留白本身就是设计语言

## 具体组件示例
- 按钮：白底黑字，细边框，大内边距（60x20pt）
- 标题：48pt 细宋体，字距 +4pt，上下留白各 80pt
- 输入框：18pt 宋体，底部 0.5pt 细线，垂直内边距 24pt
- 卡片：纯白，0 圆角，0.5pt 边框，内边距 40pt

## Mood Board 关键词
ancient Chinese poetry meets Swiss design, wabi-sabi minimalism, ink wash painting negative space, Zen interface, contemporary serif typography, monochromatic elegance, paper-like textures, breathing room, understated luxury
```

---

## Lovart 生成的规范

### 色彩系统
| 用途 | 颜色值 | 说明 |
|------|--------|------|
| 主背景 | #FFFFFF | 纯白 |
| 主文本 | #0A0A0A | 深邃墨黑 |
| 次级文本 | #4A4A4A | 中灰 |
| 辅助文本 | #ABABAB | 浅灰 |
| 强调色 | #1A1A1A | 纯黑 |
| 分割线/描边 | #E5E5E5 | 极浅灰 |

### 字体系统
| 层级 | 字体 | 字重 | 字号 |
|------|------|------|------|
| 一级标题 | 宋体/衬线 | 极细 | 72-96pt |
| 二级标题 | 宋体/衬线 | 极细 | 48-64pt |
| 正文 | 宋体 | Light | 16-20pt |
| 辅助文字 | 无衬线 | 极轻 | 12-14pt |

### 空间规范
- **内容区占比**：≤40%
- **外边距**：64-96pt
- **区块间距**：40-160pt

### UI组件规范

#### 按钮
- 高度：48pt
- 左右内边距：32pt
- 描边：1pt 或纯黑填充

#### 输入框
- 高度：40-48pt
- 下划线风格：1pt 边框

#### 卡片
- 内边距：32-40pt
- 微边框：1pt
- 圆角：4-8pt

#### 图标
- 线性风格
- 1px 描边
- 尺寸：24×24px 或 32×32px

---

## CSS 参考实现

```css
:root {
  /* 色彩系统 */
  --color-background: #FFFFFF;
  --color-text-primary: #0A0A0A;
  --color-text-secondary: #4A4A4A;
  --color-text-tertiary: #ABABAB;
  --color-accent: #1A1A1A;
  --color-divider: #E5E5E5;
  
  /* 间距系统 */
  --spacing-xl: 96px;
  --spacing-l: 64px;
  --spacing-m: 40px;
  --spacing-s: 24px;
  
  /* 字体系统 */
  --font-family-serif: 'Noto Serif SC', serif;
  --font-family-sans: 'Noto Sans SC', sans-serif;
}

body {
  background-color: var(--color-background);
  color: var(--color-text-primary);
  font-family: var(--font-family-serif);
  margin: 0;
  padding: var(--spacing-xl);
}

.container {
  max-width: 60%; /* 内容区占比不超过40% */
  margin: 0 auto;
}

h1 {
  font-weight: 200; /* 极细 */
  font-size: 72px;
  margin-bottom: var(--spacing-l);
}
```

---

## 设计资产清单

Lovart 生成的设计图片包括：

1. **字体系统示例**
   - 一级标题：宋体/衬线，极细，72-96pt
   - 二级标题：宋体/衬线，极细，48-64pt
   - 正文：宋体，Light，16-20pt
   - 辅助文字：无衬线，极轻，12-14pt

2. **色彩系统板**
   - 色卡展示：#FFFFFF, #0A0A0A, #4A4A4A, #ABABAB, #1A1A1A, #E5E5E5

3. **空间布局系统**
   - 内容区占比示意图
   - 外边距：64-96pt
   - 区块间距：40-160pt
   - Less is More 原则图解

4. **UI组件规范**
   - 按钮设计：极简矩形描边 48pt，实心按钮 48pt
   - 输入框设计：下划线风格，普通态/聚焦态
   - 卡片设计：微边框 1pt，内边距 32-40pt

5. **APP图标系统**
   - 24×24px 和 32×32px 图标规范
   - 线性风格，1px 描边
   - 示例图标：首页、诗集、创作、个人中心、搜索、设置、收藏、分享

6. **综合设计板**
   - 完整的设计系统总览
   - 包含色彩、字体、空间、UI组件的综合展示

---

## 设计理念阐述

### 古意新解
山海诗馆的设计融合了中国古典诗歌的意境美学与现代极简主义设计哲学：

- **宋代美学**：大量留白、中轴对称、墨色层级
- **瑞士设计**：理性克制、网格系统、精确间距
- **日式侘寂**：不完美之美、自然质朴、内敛优雅

### 设计语言
用**留白传递意境**，用**墨色表达层次**，用**宋体承载文化**。

每一个空白都是呼吸，每一处留白都是诗意。

---

**文档创建日期**：2024.10.22  
**Lovart 版本**：v1.0  
**设计系统版本**：山海诗馆 Design System v1.0

