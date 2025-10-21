# 山海诗馆 ShanHai Poetry Pavilion

<div align="center">

**一款极简优雅的现代诗创作与分享 iOS 应用**

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[功能特性](#-功能特性) • [技术栈](#-技术栈) • [安装运行](#-安装运行) • [项目结构](#-项目结构) • [设计理念](#-设计理念)

</div>

---

## 📖 项目简介

**山海诗馆**是一款专为现代诗爱好者打造的 iOS 应用，提供从学习、创作到分享的完整诗歌体验。应用采用极简主义设计，以纯白背景和精致字体营造优雅的阅读与创作氛围。

### 核心理念

- 🎨 **极简设计**：Dribbble 级别的高级美学，大量留白，专注内容
- 🤖 **AI 辅助**：集成 OpenAI，提供智能点评和创作建议
- 📚 **系统学习**：从零开始的现代诗创作教程
- ✍️ **多种模式**：直接写诗、模仿创作、主题写诗三种模式
- 🌐 **社区分享**：诗歌广场，欣赏他人作品

---

## ✨ 功能特性

### 1. 📚 学诗模块
- **6大主题分类**：现代诗入门、诗歌语言、节奏与结构、情感表达、经典赏析、实践指南
- **20+ 篇原创教程**：从基础概念到高级技巧的完整学习路径
- **结构化学习**：大主题 → 子主题 → 详细文章，循序渐进

### 2. ✍️ 写诗模块
#### 三种创作模式
- **直接写诗**
  - 自由创作，实时字数统计
  - 自动保存草稿
  - 标签分类管理
  
- **模仿写诗**
  - 参考经典诗歌学习
  - 分屏对比：参考诗 | 你的创作
  - 内置4首经典现代诗
  
- **主题写诗**
  - 10个意象主题（风、雨、窗、城市等）
  - AI 提供创作灵感和建议
  - 主题式引导创作

#### AI 智能功能
- **AI 点评**：从意象、情感、语言、结构四个维度分析诗歌
- **创作建议**：根据主题提供具体的意象和表达建议
- **OpenAI GPT-4o-mini**：快速响应，高质量点评

### 3. 🌐 赏诗模块
- **诗歌广场**：浏览所有已发布的诗歌
- **三种筛选**：最新、热门、随机
- **点赞收藏**：互动与保存喜欢的作品
- **详细阅读**：沉浸式诗歌阅读体验

### 4. 👤 我的模块
- **作品管理**：已发布、草稿、收藏三个分类
- **数据统计**：作品数、草稿数、获赞数
- **编辑删除**：完整的作品管理功能
- **个人主页**：优雅的个人中心设计

---

## 🛠️ 技术栈

### 核心技术
- **语言**：Swift 5.0
- **框架**：SwiftUI (声明式 UI)
- **架构**：MVVM (Model-View-ViewModel)
- **异步**：async/await (现代异步编程)
- **存储**：UserDefaults (轻量级本地存储)
- **网络**：URLSession + Combine
- **AI**：OpenAI API (GPT-4o-mini)

### 设计系统
```swift
// 颜色系统 - Dribbble 高级极简
背景：纯白 (#FFFFFF)
主文字：深邃黑 (#0A0A0A)
次要文字：中性灰 (#6B6B6B)
强调色：纯黑 (#1A1A1A)

// 字体系统 - 极致轻盈
超大标题：48pt, ultraLight, Serif
标题：28pt, ultraLight, Serif
诗歌内容：24pt, ultraLight, Serif
正文：15pt, light, Default

// 间距系统 - 大量留白
huge: 160pt
xxxl: 128pt
xxl: 96pt
xl: 64pt
lg: 40pt
```

### 项目特色
- ✅ **100% SwiftUI**：无 UIKit 依赖
- ✅ **响应式设计**：@State + @Published 实现自动更新
- ✅ **组件化开发**：高度模块化，易于维护
- ✅ **类型安全**：充分利用 Swift 的类型系统
- ✅ **代码规范**：详细注释，清晰命名

---

## 🚀 安装运行

### 环境要求
- macOS 14.0+
- Xcode 16.0+
- iOS 18.0+ (模拟器或真机)
- OpenAI API Key

### 克隆项目
```bash
git clone https://github.com/handsomeng/Shanhai-Poetry-Pavilion.git
cd Shanhai-Poetry-Pavilion
```

### 配置 API Key
打开 `BetweenLines/Utilities/Constants.swift`，找到：
```swift
static let openAIAPIKey = "你的-API-KEY"
```
替换为您的 OpenAI API Key（或在 App 设置中填写）

### 运行项目
1. 用 Xcode 打开 `BetweenLines.xcodeproj`
2. 选择目标设备（iPhone 15 Pro 推荐）
3. 按 `Cmd + R` 或点击 ▶️ 运行

---

## 📁 项目结构

```
BetweenLines/
├── Models/                      # 数据模型层
│   ├── Poem.swift              # 诗歌数据模型
│   ├── PoemManager.swift       # 诗歌管理器（CRUD + 本地存储）
│   └── LearningContent.swift   # 学习内容数据
│
├── Views/                       # 视图层
│   ├── Landing/                # 引导页
│   │   └── LandingView.swift
│   ├── Writing/                # 写诗模块
│   │   ├── WritingView.swift          # 模式选择页
│   │   ├── PoemEditorView.swift       # 通用编辑器组件
│   │   ├── DirectWritingView.swift    # 直接写诗
│   │   ├── MimicWritingView.swift     # 模仿写诗
│   │   └── ThemeWritingView.swift     # 主题写诗
│   ├── Learning/               # 学诗模块
│   │   └── LearningView.swift
│   ├── Explore/                # 赏诗模块
│   │   ├── ExploreView.swift
│   │   └── PoemDetailView.swift
│   ├── Profile/                # 我的模块
│   │   └── ProfileView.swift
│   └── Shared/                 # 共用组件
│       └── MainTabView.swift          # 主 Tab 导航
│
├── Services/                    # 服务层
│   └── AIService.swift         # OpenAI API 服务
│
├── Utilities/                   # 工具层
│   └── Constants.swift         # 设计系统常量
│
└── Assets.xcassets/            # 资源文件
    ├── AppIcon                 # 应用图标
    └── AccentColor             # 强调色

技术架构讲解_零基础版.md    # 零基础技术文档（670行）
```

---

## 🎨 设计理念

### Dribbble 高级极简美学

#### 1. 纯净的白色调
- 纯白背景 (#FFFFFF)
- 去除所有阴影和渐变
- 极细的分割线 (0.3pt)
- 几乎透明的边框

#### 2. 极致的留白
- 标题上下留白：128pt - 160pt
- 卡片间距：96pt
- 内容边距：64pt - 96pt
- 让内容呼吸，让视觉放松

#### 3. 轻盈的字体
- 全部使用 ultraLight 和 light 字重
- 大字号（48pt - 24pt）
- 增大字间距（tracking: 4-8）
- 宋体诗歌内容，优雅细腻

#### 4. 精致的细节
- 直角卡片（0pt 圆角）
- 细边框代替阴影
- 大写字母增强高级感
- 黑白灰精致配色

### 参考灵感
- Dribbble 极简作品
- Apple Human Interface Guidelines
- 日本禅意设计
- 瑞士平面设计风格

---

## 📊 数据流程

### 用户创作流程
```
1. 选择创作模式 → 2. 编辑诗歌 → 3. 添加标签 → 4. AI 点评（可选）→ 5. 保存/发布

数据流：
WritingView → DirectWritingView → PoemEditor (输入)
                ↓
          PoemManager.createDraft() (保存草稿)
                ↓
          UserDefaults (持久化)
                ↓
          ProfileView.myDrafts (显示)
```

### AI 点评流程
```
用户点击"AI 点评" → AIService.getPoemComment()
                           ↓
                    构建 Prompt + 诗歌内容
                           ↓
                    URLSession → OpenAI API
                           ↓
                    JSON 解析 ← 返回点评
                           ↓
                    显示在弹窗 + 保存到诗歌
```

---

## 🔮 开发路线图

### ✅ v1.0（已完成）
- [x] 四大核心模块
- [x] 三种写诗模式
- [x] AI 点评功能
- [x] 本地数据存储
- [x] Dribbble 级 UI

### 🚧 v1.1（进行中）
- [ ] 设置页面
- [ ] 错误处理优化
- [ ] Loading 状态
- [ ] App 图标设计
- [ ] README 文档

### 📋 v2.0（计划中）
- [ ] iCloud 同步
- [ ] 分享为图片
- [ ] 搜索和筛选
- [ ] 更多 AI 功能（续写、改写）
- [ ] iPad 适配

### 🌟 未来愿景
- [ ] 社交功能（评论、关注）
- [ ] 诗歌朗读（TTS）
- [ ] 多语言支持
- [ ] Apple Watch 版本
- [ ] macOS 版本

---

## 📄 文档

- **技术文档**：[技术架构讲解_零基础版.md](技术架构讲解_零基础版.md) (670行，零基础友好)
- **API 文档**：代码内详细注释
- **设计规范**：[Constants.swift](BetweenLines/Utilities/Constants.swift)

---

## 🤝 贡献

欢迎贡献代码、报告 Bug 或提出新功能建议！

### 如何贡献
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📝 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👨‍💻 作者

**HandsoMeng**

- GitHub: [@handsomeng](https://github.com/handsomeng)
- 项目链接: [https://github.com/handsomeng/Shanhai-Poetry-Pavilion](https://github.com/handsomeng/Shanhai-Poetry-Pavilion)

---

## 🙏 鸣谢

- **OpenAI** - 提供强大的 AI 能力
- **Apple** - 优秀的 SwiftUI 框架
- **Dribbble** - 设计灵感来源
- **所有现代诗爱好者** - 感谢你们的热爱

---

## 📸 截图预览

<div align="center">

*截图即将更新...*

</div>

---

<div align="center">

**用诗歌记录生活，用代码创造美好**

Made with ❤️ by HandsoMeng

</div>

