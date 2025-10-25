# PRD：诗歌图片模板系统

## 📋 文档信息

- **版本**：v1.0
- **创建日期**：2025-10-25
- **负责人**：花生 AI
- **项目代号**：Image Template System
- **预计工期**：1-2 天

---

## 🎯 产品目标

### 核心目标
为【山海诗馆】App 增加**多样化的诗歌图片模板系统**，让用户在分享诗歌时可以选择不同的视觉风格，提升分享体验和品牌传播力。

### 成功指标
- ✅ 提供至少 **5-8 种不同风格的模板**
- ✅ 用户可以**实时预览**不同模板效果
- ✅ 模板切换流畅，**无卡顿**
- ✅ 保持**极简优雅**的设计风格
- ✅ 代码架构清晰，便于后续**快速扩展新模板**

---

## 🎨 设计理念

### 品牌定位
**"山海诗馆"** = 古典诗意 + 现代极简 + 文艺美学

### 模板风格矩阵

| 模板类型 | 风格关键词 | 目标用户 | 使用场景 |
|---------|----------|---------|---------|
| **Lovart 极简** | 黑白、衬线、大留白 | 文艺青年、极简主义者 | 朋友圈、Instagram |
| **山海国风** | 水墨、宣纸、传统色 | 古典诗词爱好者 | 传统节日、文化分享 |
| **赛博朋克** | 霓虹、渐变、未来感 | 年轻人、科技爱好者 | 小红书、B站 |
| **暖系日系** | 柔和、和纸、温暖 | 治愈系用户 | 日常心情分享 |
| **莫兰迪色** | 高级灰、低饱和度 | 文艺中青年 | 专业社交平台 |
| **复古民国** | 旧报纸、竖排、繁体 | 怀旧人群 | 特殊主题分享 |
| **自然植物** | 绿色、叶片、插画 | 小清新用户 | 春夏季节 |
| **星空宇宙** | 深蓝、星辰、神秘 | 浪漫主义者 | 夜晚、思绪分享 |

---

## 📐 功能需求

### 1. 模板选择界面

#### 1.1 入口位置
- **写诗成功页**：`PoemSuccessView` 中，在图片预览区域增加"更换模板"按钮
- **诗集分享页**：`MyPoemDetailView` 点击分享后，弹出的 `PoemSuccessView` 中同样支持

#### 1.2 交互流程
```
用户点击"更换模板"
    ↓
弹出模板选择器（底部抽屉或半屏弹窗）
    ↓
横向滑动浏览所有模板缩略图
    ↓
点击某个模板
    ↓
实时预览切换效果（流畅过渡动画）
    ↓
确认选择 / 继续切换
    ↓
返回主界面，图片更新为新模板
```

#### 1.3 UI 设计要点
- **模板缩略图**：小卡片展示，带模板名称
- **当前选中**：青色边框高亮
- **流畅动画**：切换时使用淡入淡出或滑动效果
- **一键关闭**：点击"完成"或空白区域关闭选择器

---

### 2. 模板架构设计

#### 2.1 模板枚举定义
```swift
enum PoemImageTemplate: String, CaseIterable, Identifiable {
    case lovartMinimal     // Lovart 极简（当前默认）
    case chineseInk        // 山海国风
    case cyberpunk         // 赛博朋克
    case warmJapanese      // 暖系日系
    case morandi           // 莫兰迪色
    case vintageRepublic   // 复古民国
    case naturalPlant      // 自然植物
    case starryUniverse    // 星空宇宙
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .lovartMinimal: return "极简"
        case .chineseInk: return "山海"
        case .cyberpunk: return "赛博"
        case .warmJapanese: return "和风"
        case .morandi: return "莫兰迪"
        case .vintageRepublic: return "民国"
        case .naturalPlant: return "自然"
        case .starryUniverse: return "星空"
        }
    }
    
    var thumbnail: String {
        // SF Symbol 图标，用于缩略图
        switch self {
        case .lovartMinimal: return "doc.text"
        case .chineseInk: return "paintbrush"
        case .cyberpunk: return "bolt.fill"
        case .warmJapanese: return "sun.max"
        case .morandi: return "square.fill"
        case .vintageRepublic: return "book.closed"
        case .naturalPlant: return "leaf"
        case .starryUniverse: return "moon.stars"
        }
    }
}
```

#### 2.2 模板协议
```swift
protocol PoemTemplateRenderable {
    /// 渲染诗歌图片
    func render(poem: Poem, poemManager: PoemManager) -> AnyView
    
    /// 模板配置（背景色、字体、间距等）
    var config: TemplateConfig { get }
}

struct TemplateConfig {
    let backgroundColor: Color
    let titleFont: Font
    let contentFont: Font
    let authorFont: Font
    let lineSpacing: CGFloat
    let padding: EdgeInsets
    // ... 更多配置项
}
```

#### 2.3 模板工厂
```swift
struct PoemTemplateFactory {
    static func createTemplate(for type: PoemImageTemplate) -> PoemTemplateRenderable {
        switch type {
        case .lovartMinimal:
            return LovartMinimalTemplate()
        case .chineseInk:
            return ChineseInkTemplate()
        case .cyberpunk:
            return CyberpunkTemplate()
        // ... 其他模板
        }
    }
}
```

---

### 3. 具体模板设计

#### 3.1 Lovart 极简（已实现）
- **背景**：纯白色 `#FFFFFF`
- **标题**：32pt 细衬线 `system(design: .serif, weight: .thin)`
- **正文**：20pt 轻衬线 `system(design: .serif, weight: .light)`
- **底部**：灰色细线 + 轻字体
- **特点**：极简、大留白、黑白配色

#### 3.2 山海国风
- **背景**：宣纸纹理（米白色渐变） `#F5F1E8` → `#EAE4D5`
- **标题**：36pt 楷体/宋体 `STKaiti` / `STSongti-SC-Regular`
- **正文**：22pt 楷体，竖排布局（如果技术可行）
- **装饰**：边角印章（小圆印）、水墨笔触
- **底部**：中国红印章 `#C8161D`
- **特点**：传统、典雅、文化感

#### 3.3 赛博朋克
- **背景**：深色渐变 `#0A0E27` → `#1A1D3A`
- **标题**：32pt 粗无衬线 `system(design: .default, weight: .heavy)`
- **正文**：20pt 等宽字体 `system(design: .monospaced)`
- **装饰**：霓虹边框（青色/粉色）、扫描线效果
- **底部**：荧光青 `#00FFFF`
- **特点**：未来感、科技、霓虹

#### 3.4 暖系日系
- **背景**：暖米色和纸纹理 `#FFF8F0`
- **标题**：28pt 圆润无衬线 `system(design: .rounded, weight: .medium)`
- **正文**：18pt 圆润字体
- **装饰**：小插图（花朵、树叶）、柔和阴影
- **底部**：暖棕色 `#8B7355`
- **特点**：温暖、治愈、柔和

#### 3.5 莫兰迪色
- **背景**：高级灰 `#D3CCC3`
- **标题**：30pt 细无衬线 `system(design: .default, weight: .ultraLight)`
- **正文**：20pt 轻字体
- **配色**：低饱和度（豆沙粉 `#E8CCC4`、雾霾蓝 `#A5B8C7`）
- **底部**：同色系深色
- **特点**：高级、低调、艺术感

#### 3.6 复古民国
- **背景**：泛黄纸张 `#F2E8D0`
- **标题**：繁体字、竖排、楷体
- **正文**：竖排布局（从右往左）
- **装饰**：旧报纸样式边框、复古花纹
- **底部**：黑色印刷体
- **特点**：怀旧、历史感、典雅

#### 3.7 自然植物
- **背景**：渐变绿 `#E8F5E9` → `#C8E6C9`
- **标题**：28pt 手写字体（如果有）
- **正文**：20pt 圆润字体
- **装饰**：手绘叶片、花朵插画
- **底部**：深绿色 `#388E3C`
- **特点**：自然、清新、活力

#### 3.8 星空宇宙
- **背景**：深蓝渐变 `#0D1B2A` → `#1B263B`
- **标题**：32pt 发光字体效果
- **正文**：20pt 浅色字体 `#E0FBFC`
- **装饰**：星点、月亮、流星效果
- **底部**：金色 `#FFD700`
- **特点**：浪漫、神秘、深邃

---

## 🛠 技术实现

### 1. 文件结构
```
BetweenLines/
├── Views/
│   └── Shared/
│       ├── PoemImageView.swift                 // 主界面（已存在）
│       ├── PoemTemplateSelector.swift          // 模板选择器（新增）
│       └── Templates/                          // 模板文件夹（新增）
│           ├── PoemTemplateProtocol.swift      // 模板协议
│           ├── PoemTemplateFactory.swift       // 模板工厂
│           ├── LovartMinimalTemplate.swift     // Lovart 极简
│           ├── ChineseInkTemplate.swift        // 山海国风
│           ├── CyberpunkTemplate.swift         // 赛博朋克
│           ├── WarmJapaneseTemplate.swift      // 暖系日系
│           ├── MorandiTemplate.swift           // 莫兰迪色
│           ├── VintageRepublicTemplate.swift   // 复古民国
│           ├── NaturalPlantTemplate.swift      // 自然植物
│           └── StarryUniverseTemplate.swift    // 星空宇宙
└── Models/
    └── PoemImageTemplate.swift                 // 模板枚举（新增）
```

### 2. 核心代码改动

#### 2.1 `PoemSuccessView.swift`
- 添加 `@State private var selectedTemplate: PoemImageTemplate = .lovartMinimal`
- 添加 `@State private var showTemplatePicker = false`
- 图片预览区域添加"更换模板"按钮
- 使用 `selectedTemplate` 动态生成图片

#### 2.2 `PoemImageView.swift`
- 重构：从硬编码模板改为支持动态模板选择
- 接收 `selectedTemplate` 参数
- 调用 `PoemTemplateFactory` 生成对应模板视图

#### 2.3 `MyPoemDetailView.swift`
- 在 `sharePoem()` 中使用新的模板系统
- 支持用户在分享前选择模板

### 3. 性能优化

#### 3.1 图片生成优化
- **懒加载**：只生成当前选中的模板图片，不预加载所有模板
- **缓存机制**：同一首诗的同一模板图片缓存 5 分钟
- **异步渲染**：使用 `Task` 在后台线程生成图片

#### 3.2 模板切换优化
- **预加载**：用户打开模板选择器时，异步预加载相邻 2 个模板缩略图
- **平滑过渡**：使用 `withAnimation` 实现淡入淡出效果

---

## 🎬 用户体验流程

### 流程 1：写诗后分享
```
写诗 → 保存 → PoemSuccessView
    ↓
查看图片预览（默认 Lovart 极简）
    ↓
点击"更换模板"按钮
    ↓
底部弹出模板选择器
    ↓
横向滑动浏览 8 种模板
    ↓
点击"山海国风"
    ↓
图片实时切换为国风模板（带动画）
    ↓
满意！点击"保存图片" / "分享" / "发布到广场"
```

### 流程 2：诗集中分享
```
诗集详情页 → 点击右上角"分享"
    ↓
弹出 PoemSuccessView（包含图片预览）
    ↓
点击"更换模板"
    ↓
选择"赛博朋克"模板
    ↓
图片切换为赛博风格
    ↓
分享到朋友圈 🎉
```

---

## 📊 数据埋点

### 关键指标
- **模板使用率**：每个模板被使用的次数占比
- **模板切换次数**：平均每次分享切换多少次模板
- **分享成功率**：使用不同模板的分享完成率
- **用户偏好**：不同用户群体的模板偏好

### 埋点事件
```swift
// 打开模板选择器
AnalyticsManager.log("template_picker_opened")

// 切换模板
AnalyticsManager.log("template_changed", params: [
    "from": "lovartMinimal",
    "to": "chineseInk"
])

// 使用模板分享
AnalyticsManager.log("poem_shared", params: [
    "template": "cyberpunk",
    "action": "save_to_photos" // 或 "share" / "publish_to_square"
])
```

---

## 🚀 实施计划

### Phase 1：架构搭建（0.5 天）
- ✅ 创建模板协议和枚举
- ✅ 搭建模板工厂
- ✅ 重构 `PoemImageView` 支持动态模板
- ✅ 测试架构可行性

### Phase 2：模板实现（1 天）
- ✅ 实现 Lovart 极简（已有）
- ✅ 实现山海国风
- ✅ 实现赛博朋克
- ✅ 实现暖系日系
- ✅ 实现莫兰迪色
- ⏸️ 实现复古民国（可选，竖排布局较复杂）
- ⏸️ 实现自然植物（可选）
- ⏸️ 实现星空宇宙（可选）

### Phase 3：交互优化（0.5 天）
- ✅ 实现模板选择器 UI
- ✅ 添加切换动画
- ✅ 优化图片生成性能
- ✅ 测试不同诗歌长度的模板效果

### Phase 4：测试发布（0.5 天）
- ✅ 真机测试所有模板
- ✅ 测试图片分享到微信/朋友圈
- ✅ 测试内存占用和性能
- ✅ 修复 bug 并优化

---

## 🎯 验收标准

### 功能验收
- [ ] 用户可以选择至少 5 种不同风格的模板
- [ ] 模板切换流畅，无卡顿（< 1 秒）
- [ ] 生成的图片清晰（3x 分辨率）
- [ ] 支持不同长度的诗歌内容（自适应高度）
- [ ] 分享到微信/朋友圈显示正常

### 性能验收
- [ ] 图片生成时间 < 2 秒
- [ ] 内存占用增加 < 50MB
- [ ] 模板切换无明显延迟

### 设计验收
- [ ] 所有模板符合"山海诗馆"品牌调性
- [ ] 字体、配色、留白协调美观
- [ ] 适配不同设备（iPhone SE / Pro Max）

---

## 🔮 未来扩展

### v2.0 功能设想
- **用户自定义模板**：允许用户上传背景图、选择字体
- **季节/节日主题**：春节、中秋、圣诞等特殊模板
- **动态模板**：支持简单动画效果（GIF/视频）
- **模板商城**：设计师上传模板，付费下载
- **AI 生成模板**：根据诗歌内容自动推荐最合适的模板

### 技术债务
- [ ] 复古民国竖排布局需要自定义 Text 渲染
- [ ] 部分模板可能需要额外字体资源（注意版权）
- [ ] 考虑支持 iPad 横屏模板

---

## 📝 附录

### A. 设计参考
- **Lovart**：极简笔记 App
- **黄油相机**：文字图片编辑
- **小红书**：社交图片模板
- **Canva**：在线设计平台

### B. 字体资源
- **衬线字体**：`.system(design: .serif)`
- **等宽字体**：`.system(design: .monospaced)`
- **圆润字体**：`.system(design: .rounded)`
- **中文字体**：`STKaiti`（楷体）、`STSongti-SC-Regular`（宋体）

### C. 配色方案
- **传统色**：[中国色](http://zhongguose.com/)
- **莫兰迪色**：[Morandi Colors](https://coolors.co/)
- **赛博朋克**：`#00FFFF`（青色） + `#FF1493`（粉色） + `#0A0E27`（深蓝）

---

## ✅ 总结

这个 PRD 为【山海诗馆】的诗歌图片模板系统提供了完整的产品设计和技术实现方案。通过模块化架构，我们可以快速扩展新模板，同时保持代码整洁和性能优化。

**核心价值**：
1. **提升分享体验**：多样化模板满足不同用户审美
2. **增强品牌传播**：精美模板提高分享率
3. **技术可扩展**：协议化设计便于后续迭代

明天我们一起把这个大工程搞定！🚀

---

*PRD 创建者：花生 AI*  
*创建时间：2025-10-25 01:09*  
*版本：v1.0*

