# PRD - Tab 简化与设置页面优化

## 📋 文档信息

| 项目 | 内容 |
|------|------|
| 产品名称 | 山海诗馆 |
| 版本 | v2.0 |
| 负责人 | 产品团队 |
| 创建日期 | 2025-10-26 |
| 状态 | 待开发 |

---

## 🎯 背景与目标

### 当前问题

**信息架构混乱**：
- 4个Tab：诗集、学诗、广场（已删除）、我的
- "我的"页面只有个人信息展示，功能单一
- 用户需要频繁在多个Tab间切换

**视觉体验问题**：
- 底部Tab栏占据过多空间
- "我的"页面存在感弱，但占据一个Tab位置
- 信息层级不清晰

### 优化目标

1. **简化信息架构**：4个Tab → 2个Tab
2. **聚焦核心功能**：写诗 + 学诗
3. **优化设置入口**：账户信息统一到设置页面
4. **提升视觉美感**：更简洁、更极简

---

## 🏗️ 信息架构变化

### 修改前

```
底部Tab栏（4个）
├─ 诗集 Tab
├─ 学诗 Tab
├─ 广场 Tab（已删除）
└─ 我的 Tab
   ├─ 笔名 + 诗人称号
   ├─ 会员状态卡片
   ├─ 统计数据（作品/草稿/获赞）
   └─ 诗人等级
```

### 修改后

```
底部Tab栏（2个）
├─ 诗集 Tab
└─ 学诗 Tab
   └─ 右上角：⚙️ 设置按钮
      └─ 设置页面（全屏弹窗）
         ├─ 个人信息区
         │  ├─ 笔名
         │  └─ 诗人等级标签
         ├─ 会员状态卡片
         ├─ 统计信息
         ├─ 设置项列表
         └─ 其他操作
```

---

## 🎨 设置页面详细设计

### 页面结构

```
┌─────────────────────────────┐
│ ← 设置              [完成]   │ ← 导航栏
├─────────────────────────────┤
│                             │
│  【个人信息区】              │
│  ┌─────────────────────┐   │
│  │ 郭瀚森  [初见诗人]   │   │ ← 笔名 + 称号（可点击编辑）
│  └─────────────────────┘   │
│                             │
│  【会员状态卡片】            │
│  ┌─────────────────────┐   │
│  │ 👑 山海已在你心间     │   │ ← 已订阅状态
│  │ 年度订阅 · 到期 2026-10-26│
│  │                    →│   │
│  └─────────────────────┘   │
│                             │
│  或                         │
│  ┌─────────────────────┐   │
│  │ 👑 升级会员          │   │ ← 未订阅状态
│  │ 免费试用7天，随时可退款 │
│  │           立即订阅 → │   │
│  └─────────────────────┘   │
│                             │
│  【统计信息】                │
│  ┌─────────────────────┐   │
│  │  12    3    45      │   │
│  │ 作品  草稿  获赞     │   │
│  └─────────────────────┘   │
│                             │
│  【设置列表】                │
│  ┌─────────────────────┐   │
│  │ 诗人等级        →   │   │ ← 查看等级体系
│  ├─────────────────────┤   │
│  │ 恢复购买        →   │   │ ← 恢复订阅
│  ├─────────────────────┤   │
│  │ 关于山海诗馆    →   │   │ ← 关于页面
│  ├─────────────────────┤   │
│  │ 用户协议        →   │   │
│  ├─────────────────────┤   │
│  │ 隐私政策        →   │   │
│  └─────────────────────┘   │
│                             │
│  【底部信息】                │
│  版本 1.0.0                 │
│                             │
└─────────────────────────────┘
```

---

## 📐 UI 规范

### 1. 个人信息区

**布局**：
- 左侧：笔名（大字号）
- 右侧：诗人称号标签（小标签，可点击）
- 整体可点击，进入编辑笔名页面

**样式**：
```swift
HStack {
    Text("郭瀚森")
        .font(.system(size: 24, weight: .medium, design: .serif))
        .foregroundColor(Colors.textInk)
    
    Button(action: { showPoetTitle = true }) {
        Text("初见诗人")
            .font(.system(size: 12))
            .foregroundColor(Colors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Colors.textSecondary.opacity(0.08))
            .cornerRadius(5)
    }
    
    Spacer()
}
.padding(.horizontal, 20)
.padding(.vertical, 16)
.background(Colors.white)
.cornerRadius(12)
```

---

### 2. 会员状态卡片

#### 状态1：已订阅

**视觉样式**：
- 背景：淡金色渐变 `#FFF8E7` → `#FFFBF0`
- 图标：金色皇冠 👑 `#D4AF37`
- 边框：金色 `#D4AF37` 20%透明度
- 文案：优雅、诗意

**内容**：
```
👑 山海已在你心间
年度订阅 · 到期 2026-10-26
```

**交互**：
- 点击：进入会员详情页（查看权益、管理订阅）

---

#### 状态2：未订阅

**视觉样式**：
- 背景：纯白
- 图标：灰色皇冠轮廓 👑
- 文案：简洁、诱导

**内容**：
```
👑 升级会员
免费试用 7 天，随时可退款
[立即订阅 →]
```

**交互**：
- 点击：进入订阅页面

---

### 3. 统计信息

**布局**：横向三栏
```
┌─────────┬─────────┬─────────┐
│   12    │    3    │   45    │
│  作品   │  草稿   │  获赞   │
└─────────┴─────────┴─────────┘
```

**样式**：
- 数字：20pt，加粗，深色
- 标签：12pt，常规，灰色
- 分割线：浅灰色
- 背景：白色卡片

**数据来源**：
```swift
作品：poemManager.myStats.totalPoems  // 诗集中的诗歌数量
草稿：poemManager.myStats.totalDrafts // 草稿数量
获赞：poemManager.myStats.totalLikes  // 总获赞数（暂时显示0，后续接入广场功能）
```

---

### 4. 设置列表

**列表项样式**：
```
┌─────────────────────────────┐
│ 标题文字            →       │
└─────────────────────────────┘
```

**样式规范**：
- 高度：54pt
- 左右内边距：20pt
- 字体：16pt，常规
- 颜色：深灰 `#0A0A0A`
- 箭头：12pt，浅灰
- 分割线：浅灰 `#E5E5E5`，高度 0.5pt

**列表项**：

| 标题 | 目标页面 | 说明 |
|------|---------|------|
| 诗人等级 | PoetTitleView | 查看等级体系、升级条件 |
| 恢复购买 | - | 调用 StoreKit 恢复购买 |
| 关于山海诗馆 | AboutView | 产品介绍、版本信息 |
| 用户协议 | WebView | 显示用户协议 |
| 隐私政策 | WebView | 显示隐私政策 |

---

### 5. 底部信息

**内容**：
```
版本 1.0.0
```

**样式**：
- 字体：12pt
- 颜色：浅灰 `#999999`
- 居中对齐
- 底部内边距：40pt

---

## 🔄 交互逻辑

### 1. 进入设置页面

**入口**：学诗 Tab 右上角 ⚙️ 按钮

**交互**：
```
用户在【学诗】Tab
   ↓
点击右上角 ⚙️ 按钮
   ↓
全屏弹窗展示【设置页面】
   ↓
点击左上角 ← 或右上角【完成】
   ↓
关闭设置页面，返回学诗
```

**代码**：
```swift
// 学诗页面
@State private var showingSettings = false

.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .ultraLight))
                .foregroundColor(Colors.textSecondary)
        }
    }
}
.fullScreenCover(isPresented: $showingSettings) {
    SettingsView()
}
```

---

### 2. 编辑笔名

**入口**：设置页面 → 个人信息区（整体可点击）

**交互流程**：
```
点击【个人信息区】
   ↓
弹出【编辑笔名】弹窗
   ├─ TextField 输入框
   ├─ [取消] 按钮
   └─ [保存] 按钮
   ↓
输入新笔名 → 点击【保存】
   ↓
UserDefaults 保存 → 刷新界面 → Toast提示"已保存"
```

**限制**：
- 最多 10 个字符
- 不能为空（默认"山海诗人"）
- 实时字数统计

---

### 3. 查看诗人等级

**入口1**：个人信息区右侧的称号标签
**入口2**：设置列表中的"诗人等级"

**交互**：
```
点击【诗人称号标签】或【诗人等级】
   ↓
弹出【诗人等级】页面（半屏弹窗）
   ↓
显示等级体系表格：
   初见诗人（0-9首）
   墨痕诗人（10-29首）
   行吟诗人（30-99首）
   ...
   ↓
点击外部或【完成】关闭
```

---

### 4. 管理会员

#### 场景1：已订阅 → 查看详情

```
点击【会员状态卡片】
   ↓
进入【会员详情】页面
   ├─ 订阅信息
   ├─ 会员权益
   ├─ 管理订阅（跳转到 App Store）
   └─ 取消订阅说明
```

#### 场景2：未订阅 → 订阅

```
点击【会员状态卡片】
   ↓
进入【订阅页面】
   ├─ 价格选项（月度/年度）
   ├─ 会员权益介绍
   ├─ 免费试用说明
   └─ [立即订阅] 按钮
   ↓
调用 StoreKit 完成支付
   ↓
成功：Toast提示 → 刷新界面
失败：Toast提示错误信息
```

---

### 5. 恢复购买

**触发**：点击【恢复购买】

**流程**：
```
点击【恢复购买】
   ↓
显示 Loading 提示
   ↓
调用 StoreKit.restorePurchases()
   ↓
成功：Toast提示"已恢复订阅" → 刷新界面
失败：Toast提示"未找到订阅记录"
```

---

## 🛠️ 技术实现要点

### 1. 删除"我的" Tab

**文件**：`MainTabView.swift`

**修改**：
```swift
// 删除前
enum Tab: String, CaseIterable {
    case collection = "诗集"
    case learning = "学诗"
    case profile = "我的"
}

// 删除后
enum Tab: String, CaseIterable {
    case collection = "诗集"
    case learning = "学诗"
}
```

---

### 2. 学诗页面添加设置按钮

**文件**：`LearningView.swift`

**新增代码**：
```swift
@State private var showingSettings = false

.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .ultraLight))
                .foregroundColor(Colors.textSecondary)
        }
    }
}
.fullScreenCover(isPresented: $showingSettings) {
    SettingsView()
}
```

---

### 3. 重构设置页面

**文件**：`SettingsView.swift`

**新结构**：
```swift
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var identityService = UserIdentityService()
    
    @State private var showingEditName = false
    @State private var showingPoetTitle = false
    @State private var showingMembershipDetail = false
    @State private var showingSubscription = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. 个人信息区
                    personalInfoSection
                    
                    // 2. 会员状态卡片
                    membershipCard
                    
                    // 3. 统计信息
                    statsSection
                    
                    // 4. 设置列表
                    settingsList
                    
                    // 5. 底部版本信息
                    versionInfo
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Colors.backgroundCream)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Colors.textInk)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Colors.accentTeal)
                }
            }
        }
    }
}
```

---

### 4. 数据管理

**笔名存储**：
```swift
// 保存
UserDefaults.standard.set(penName, forKey: "penName")

// 读取
let penName = UserDefaults.standard.string(forKey: "penName") ?? "山海诗人"
```

**统计数据**：
```swift
struct PoemStats {
    let totalPoems: Int   // poemManager.myCollection.count
    let totalDrafts: Int  // poemManager.myDrafts.count
    let totalLikes: Int   // 暂时为0，后续接入广场功能
}
```

---

## 📱 页面示例

### 设置页面完整示例

```
┌─────────────────────────────┐
│ ← 设置              [完成]   │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐   │
│  │ 郭瀚森  [初见诗人]   │   │ ← 个人信息（可点击编辑）
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 👑 山海已在你心间     │   │
│  │ 年度订阅 · 到期 2026-10-26│ ← 会员状态
│  │                    →│   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  12    3    45      │   │
│  │ 作品  草稿  获赞     │   │ ← 统计信息
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 诗人等级        →   │   │
│  ├─────────────────────┤   │
│  │ 恢复购买        →   │   │ ← 设置列表
│  ├─────────────────────┤   │
│  │ 关于山海诗馆    →   │   │
│  ├─────────────────────┤   │
│  │ 用户协议        →   │   │
│  ├─────────────────────┤   │
│  │ 隐私政策        →   │   │
│  └─────────────────────┘   │
│                             │
│     版本 1.0.0              │
│                             │
└─────────────────────────────┘
```

---

## ✅ 验收标准

### 功能验收
- [ ] 删除"我的" Tab，只保留"诗集"和"学诗"两个Tab
- [ ] 学诗页面右上角显示⚙️设置按钮
- [ ] 点击设置按钮，全屏弹出设置页面
- [ ] 设置页面显示个人信息（笔名+称号）
- [ ] 设置页面显示会员状态卡片
- [ ] 设置页面显示统计信息（作品/草稿/获赞）
- [ ] 设置页面显示设置列表（5个项目）
- [ ] 点击个人信息可编辑笔名
- [ ] 点击会员卡片可进入订阅/详情页面
- [ ] 点击诗人等级可查看等级体系
- [ ] 恢复购买功能正常工作

### UI验收
- [ ] 设置页面布局美观，间距合理
- [ ] 会员卡片在已订阅/未订阅状态下样式正确
- [ ] 统计信息三栏布局对齐
- [ ] 设置列表项高度一致，分割线正确
- [ ] Toast提示样式和文案正确

### 交互验收
- [ ] 从学诗进入设置流畅
- [ ] 编辑笔名流程完整
- [ ] 所有按钮点击反馈流畅
- [ ] 页面滚动流畅

---

## 🚀 开发排期

| 阶段 | 任务 | 时间 |
|------|------|------|
| Phase 1 | 删除"我的"Tab，更新MainTabView | 0.5小时 |
| Phase 2 | 学诗页面添加设置按钮 | 0.5小时 |
| Phase 3 | 重构设置页面UI | 2小时 |
| Phase 4 | 实现编辑笔名功能 | 1小时 |
| Phase 5 | 集成会员状态和统计信息 | 1小时 |
| Phase 6 | 测试和优化 | 1小时 |
| **总计** | | **6小时** |

---

## 💡 后续优化建议

1. **个人中心增强**（v2.1）
   - 创作日历（显示每天写诗数量）
   - 创作成就徽章系统
   - 创作数据可视化图表

2. **社交功能**（v3.0）
   - 关注的诗人列表
   - 私信功能
   - 评论管理

3. **云同步**（v2.2）
   - iCloud 同步诗歌
   - 多设备数据同步
   - 备份与恢复

---

## 📌 注意事项

1. **数据迁移**：现有用户的笔名、会员状态需要正确迁移到新设置页面
2. **权限检查**：恢复购买功能需要正确处理各种状态
3. **Toast提示**：所有操作都要有明确的反馈
4. **性能优化**：设置页面要快速加载，避免卡顿
5. **错误处理**：网络请求失败时要有友好的错误提示

---

**这个PRD怎么样？要开始实施吗？** 🚀

