# 诗歌图片模板系统 PRD v2.0

## 📋 文档信息

- **版本**：v2.0
- **创建日期**：2024-10-26
- **负责人**：AI助手
- **状态**：待开发

---

## 🎯 项目目标

为用户提供多样化的诗歌图片模板，让每首诗都能以最适合的视觉风格呈现，提升分享体验。

### **核心价值**
1. **个性化表达**：不同风格满足不同场景和心情
2. **视觉美学**：每个模板都是精心设计的艺术品
3. **分享动力**：精美的图片激发用户分享欲望

---

## 🎨 模板设计方案

### **模板 1：Lovart 极简**（当前默认）

**设计理念**：极简主义，纯净优雅

**视觉特征**：
- 背景：纯白色 `#FFFFFF`
- 标题：20pt 中等字重，黑色 `#0A0A0A`
- 正文：15pt 常规字重，深灰 `#333333`
- 顶部：日期（左）+ "山海诗馆"（右）
- 底部：作者名（右对齐）

**适用场景**：文艺、日常、通用

---

### **模板 2：山海国风**

**设计理念**：中国传统美学，水墨意境

**视觉特征**：
- 背景：米色渐变 `#F5F0E8` → `#EDE8DC`
- 装饰元素：水墨纹理（淡化 10% 不透明度）
- 标题：24pt 书法风格字体，墨色 `#2C2C2C`
- 正文：16pt 楷体，深棕 `#4A3C2A`
- 印章装饰：右下角红色方章（"山海诗馆"）
- 顶部边缘：云纹装饰
- 底部：作者名 + 日期（竖排，右侧）

**适用场景**：古风诗词、传统节日、文化氛围

---

### **模板 3：暖系日系**

**设计理念**：温暖治愈，日系美学

**视觉特征**：
- 背景：暖米色 `#FFF8F0`
- 装饰元素：淡淡的纸质纹理
- 标题：22pt 圆润字体，棕色 `#8B7355`
- 正文：16pt 柔和字体，暖灰 `#6B5D4F`
- 边框：细线虚线边框，米色 `#E8DCC8`
- 角落装饰：小花朵水彩插画（左上角）
- 底部：波浪线分隔 + 日期 + 作者名

**适用场景**：治愈系、生活随笔、心情记录

---

### **模板 4：深夜暗黑**

**设计理念**：深邃神秘，夜间阅读友好

**视觉特征**：
- 背景：深灰黑 `#1C1C1E`
- 标题：20pt 细体，亮灰 `#E5E5EA`
- 正文：15pt 常规，中灰 `#C7C7CC`
- 顶部：日期（左）+ "山海诗馆"（右），暗灰
- 底部：作者名（右对齐），暗灰
- 边缘：微光效果（2px 亮边）

**适用场景**：深夜、情绪诗、严肃主题

---

### **模板 5：赛博朋克**

**设计理念**：未来科技，霓虹美学

**视觉特征**：
- 背景：深蓝紫渐变 `#1A1A2E` → `#16213E`
- 标题：22pt 等宽字体，青色 `#0FF4C6`
- 正文：15pt 等宽字体，白色 `#FFFFFF`
- 装饰元素：
  - 扫描线效果（水平细线，5px 间隔）
  - 边角框线（青色霓虹）
  - 故障艺术文字效果（标题）
- 顶部：日期 + 时间（左），数字格式
- 底部：作者名（左）+ "BETWEENLINES"（右）

**适用场景**：科幻、实验性、年轻态

---

### **模板 6：手写笔记**

**设计理念**：手写温度，真实感

**视觉特征**：
- 背景：笔记本纸质感 `#FFFEF7`
- 横线：淡蓝色横线（如活页纸）
- 标题：20pt 手写风格字体，黑色
- 正文：16pt 手写风格，深蓝 `#1A4D8F`
- 装饰元素：
  - 左侧红色竖线（活页纸样式）
  - 随机墨点（模拟钢笔书写）
  - 轻微倾斜（2-3度）
- 底部：手写签名效果

**适用场景**：手账风、个人日记、情书

---

## 🎬 交互流程

### **流程 1：查看当前模板**

```
诗歌详情页 → 点击"分享"
    ↓
进入分享页面
    ↓
显示当前选择的模板（默认：Lovart 极简）
```

---

### **流程 2：更换模板**

```
分享页面 → 点击底部"更换模板"按钮
    ↓
弹出模板选择器（半屏弹窗）
    ↓
横向滑动浏览所有模板
    ↓
点击某个模板卡片
    ↓
预览图实时切换为该模板
    ↓
可继续选择其他模板（实时预览）
    ↓
点击"完成"或点击外部 → 关闭选择器
```

---

### **流程 3：保存/分享**

```
选择好模板后 → 点击"保存图片"或分享按钮
    ↓
使用当前选择的模板生成高清图片
    ↓
执行保存/分享操作
```

---

## 📱 UI 设计

### **1. 模板选择器（半屏弹窗）**

```
┌─────────────────────────────────────┐
│  选择模板                    完成    │
├─────────────────────────────────────┤
│                                     │
│  ← [模板卡片1] [模板卡片2] [卡片3] →│
│                                     │
│     可横向滑动                       │
│                                     │
└─────────────────────────────────────┘
```

**卡片规格**：
- 尺寸：宽 140pt，高 220pt
- 间距：12pt
- 内容：模板缩略图 + 模板名称
- 当前选中：青色边框（2pt）
- 未选中：灰色边框（1pt）

---

### **2. 模板卡片**

```
┌───────────────┐
│               │
│   [缩略图]    │ ← 140x180pt
│               │
│               │
├───────────────┤
│  Lovart 极简  │ ← 模板名称
└───────────────┘
```

**交互状态**：
- **默认**：灰色边框 `#E5E5E5`
- **选中**：青色边框 `#4FC3C3` + 阴影
- **按压**：缩放到 97%

---

### **3. 模板缩略图内容**

**显示内容**：
- 诗歌前 4 行（或前 50 字）
- 完整的装饰元素（但缩小）
- 真实的配色方案

**比例**：
- 原图 340pt → 缩略图 140pt（约 41% 缩放）

---

## 💻 技术实现

### **1. 模板协议定义**

```swift
protocol PoemTemplate {
    var id: String { get }
    var name: String { get }
    var icon: String { get } // SF Symbol 或 emoji
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View
}
```

---

### **2. 模板枚举**

```swift
enum PoemTemplateType: String, CaseIterable {
    case lovartMinimal = "Lovart 极简"
    case mountainSea = "山海国风"
    case warmJapanese = "暖系日系"
    case darkNight = "深夜暗黑"
    case cyberpunk = "赛博朋克"
    case handwritten = "手写笔记"
    
    var template: any PoemTemplate {
        switch self {
        case .lovartMinimal: return LovartMinimalTemplate()
        case .mountainSea: return MountainSeaTemplate()
        case .warmJapanese: return WarmJapaneseTemplate()
        case .darkNight: return DarkNightTemplate()
        case .cyberpunk: return CyberpunkTemplate()
        case .handwritten: return HandwrittenTemplate()
        }
    }
}
```

---

### **3. 文件结构**

```
Views/Share/
├── PoemShareView.swift              # 分享主页面
├── TemplateSelector.swift           # 模板选择器
└── Templates/
    ├── PoemTemplateProtocol.swift   # 模板协议
    ├── LovartMinimalTemplate.swift  # Lovart 极简
    ├── MountainSeaTemplate.swift    # 山海国风
    ├── WarmJapaneseTemplate.swift   # 暖系日系
    ├── DarkNightTemplate.swift      # 深夜暗黑
    ├── CyberpunkTemplate.swift      # 赛博朋克
    └── HandwrittenTemplate.swift    # 手写笔记
```

---

### **4. 关键代码示例**

#### **模板渲染**

```swift
struct LovartMinimalTemplate: PoemTemplate {
    var id = "lovart_minimal"
    var name = "Lovart 极简"
    var icon = "🤍"
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部：日期 + logo
            HStack {
                Text(poem.createdAt, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "999999"))
                Spacer()
                Text("山海诗馆")
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(Color(hex: "CCCCCC"))
            }
            .padding(.bottom, 24)
            
            // 标题 + 正文 + 作者名
            // ...
        }
        .padding(32)
        .frame(width: size.width)
        .background(Color.white)
    }
}
```

#### **模板选择器**

```swift
struct TemplateSelector: View {
    @Binding var selectedTemplate: PoemTemplateType
    @Environment(\.dismiss) private var dismiss
    let poem: Poem
    
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PoemTemplateType.allCases, id: \.self) { type in
                        TemplateCard(
                            template: type,
                            poem: poem,
                            isSelected: selectedTemplate == type,
                            action: {
                                selectedTemplate = type
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

---

### **5. 图片生成优化**

```swift
@MainActor
func renderPoemAsImage(template: PoemTemplateType) async -> UIImage? {
    let templateView = template.template.render(
        poem: poem,
        size: CGSize(width: 340, height: 0) // 高度自适应
    )
    
    let renderer = ImageRenderer(content: templateView)
    renderer.scale = 3.0 // 3x 高清
    
    return renderer.uiImage
}
```

---

## 🎨 设计规范

### **颜色系统**

| 模板 | 主色调 | 文字色 | 背景色 |
|------|--------|--------|--------|
| Lovart 极简 | 黑白 | `#333333` | `#FFFFFF` |
| 山海国风 | 米棕 | `#4A3C2A` | `#F5F0E8` |
| 暖系日系 | 暖米 | `#6B5D4F` | `#FFF8F0` |
| 深夜暗黑 | 冷灰 | `#C7C7CC` | `#1C1C1E` |
| 赛博朋克 | 青紫 | `#FFFFFF` | `#1A1A2E` |
| 手写笔记 | 蓝灰 | `#1A4D8F` | `#FFFEF7` |

---

### **字体系统**

| 模板 | 标题字体 | 正文字体 | 字号 |
|------|----------|----------|------|
| Lovart 极简 | 宋体 Medium | 宋体 Regular | 20pt / 15pt |
| 山海国风 | 楷体 Bold | 楷体 Regular | 24pt / 16pt |
| 暖系日系 | 圆体 Medium | 圆体 Regular | 22pt / 16pt |
| 深夜暗黑 | 宋体 Thin | 宋体 Regular | 20pt / 15pt |
| 赛博朋克 | 等宽 Bold | 等宽 Regular | 22pt / 15pt |
| 手写笔记 | 手写体 | 手写体 | 20pt / 16pt |

---

## 🚀 实施计划

### **Phase 1：基础架构（0.5天）**
1. ✅ 定义 `PoemTemplate` 协议
2. ✅ 创建 `PoemTemplateType` 枚举
3. ✅ 搭建 `Templates/` 文件夹结构
4. ✅ 实现 `TemplateSelector` 模板选择器

### **Phase 2：核心模板实现（1天）**
5. ✅ `LovartMinimalTemplate`（已有）
6. ✅ `MountainSeaTemplate`（山海国风）
7. ✅ `WarmJapaneseTemplate`（暖系日系）
8. ✅ `DarkNightTemplate`（深夜暗黑）

### **Phase 3：高级模板实现（1天）**
9. ✅ `CyberpunkTemplate`（赛博朋克）
10. ✅ `HandwrittenTemplate`（手写笔记）
11. ✅ 模板缩略图生成优化
12. ✅ 模板切换动画优化

### **Phase 4：集成和优化（0.5天）**
13. ✅ 集成到 `PoemShareView`
14. ✅ 用户选择持久化（记住上次选择的模板）
15. ✅ 性能优化（缓存渲染结果）
16. ✅ 测试和bug修复

---

## ✅ 验收标准

### **功能验收**
- ✅ 可以查看所有 6 种模板
- ✅ 点击模板卡片实时切换预览
- ✅ 生成的图片与预览一致
- ✅ 所有模板都能正常保存和分享
- ✅ 模板选择器流畅滑动

### **视觉验收**
- ✅ 每个模板风格独特，辨识度高
- ✅ 字体、配色、布局符合设计规范
- ✅ 生成的图片清晰（3x 分辨率）
- ✅ 缩略图准确反映实际效果

### **性能验收**
- ✅ 模板切换延迟 < 0.5 秒
- ✅ 图片生成时间 < 2 秒
- ✅ 内存占用合理（< 100MB）
- ✅ 横向滑动流畅（60fps）

---

## 🎯 后续优化

### **V2.1 功能**
- 🚧 用户自定义模板（颜色、字体）
- 🚧 社区模板分享
- 🚧 季节性/节日限定模板
- 🚧 AI 自动推荐模板

### **V2.2 功能**
- 🚧 动态模板（动画效果）
- 🚧 视频分享
- 🚧 模板收藏功能
- 🚧 模板使用统计

---

## 📝 注意事项

1. **性能优化**：
   - 模板预览使用低分辨率渲染（1x）
   - 最终图片使用高分辨率渲染（3x）
   - 缓存已渲染的缩略图

2. **兼容性**：
   - iOS 15+ 支持
   - 适配 iPhone 和 iPad
   - 支持暗黑模式（部分模板）

3. **用户体验**：
   - 首次使用时提供模板介绍引导
   - 记住用户上次选择的模板
   - 提供"恢复默认"选项

4. **技术限制**：
   - 部分复杂装饰元素可能需要 SVG 或图片资源
   - 手写字体需要额外字体文件
   - 赛博朋克效果需要 Shader 或特殊渲染

---

## 🎨 设计参考

- **Lovart 极简**：参考 Notion、Bear
- **山海国风**：参考传统水墨画、古籍排版
- **暖系日系**：参考 Hobonichi、无印良品
- **深夜暗黑**：参考 GitHub Dark、VS Code
- **赛博朋克**：参考《攻壳机动队》、霓虹美学
- **手写笔记**：参考手账文化、钢笔书写

---

**✅ PRD 完成！准备开始实施！**

