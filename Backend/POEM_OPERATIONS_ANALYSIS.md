# 📝 诗歌操作逻辑梳理文档

## 🎯 目标
梳理写诗页面和"我的"页面中所有与诗歌保存、编辑、删除相关的按钮和逻辑，找出问题并提出重构方案。

---

## 📍 涉及的页面

### 1. 写诗模式（3个）
- **DirectWritingView**（自由写诗）
- **MimicWritingView**（临摹写诗）
- **ThemeWritingView**（主题写诗）

### 2. 个人页面
- **ProfileView**（我的）
- **PoemEditorDetailView**（诗歌详情/编辑）

---

## 🔍 当前逻辑分析

### 一、写诗页面的保存逻辑

#### 1.1 底部操作按钮（3个）

```
[草稿]  [诗集]  [发布]
```

**当前实现**：
```swift
// 草稿按钮
Button("草稿") {
    saveDraft()
}

// 诗集按钮
Button("诗集") {
    saveToCollection()
}

// 发布按钮
Button("发布") {
    if authService.isAuthenticated {
        publishToSquare()
    } else {
        showLoginSheet = true
    }
}
```

#### 1.2 保存逻辑（3种方式）

##### 方式1：保存为草稿
```swift
func saveDraft() {
    if authService.isAuthenticated {
        // → 后端草稿（云端）
        poemService.saveDraft(...)
    } else {
        // → 本地草稿（UserDefaults）
        poemManager.createDraft(...)
    }
    dismiss()  // 关闭页面
}
```

##### 方式2：保存到诗集
```swift
func saveToCollection() {
    // → 本地诗集（UserDefaults）
    let newPoem = poemManager.createPoem(...)
    poemManager.savePoem(newPoem)
    
    // 显示分享面板
    showingShareSheet = true
}
```

##### 方式3：发布到广场
```swift
func publishToSquare() {
    guard authService.isAuthenticated else { return }
    
    // → 后端发布（Supabase）
    poemService.publishPoem(...)
    dismiss()  // 关闭页面
}
```

#### 1.3 取消/退出逻辑

```swift
// 点击"取消"按钮
func handleCancel() {
    if !content.isEmpty {
        // 显示确认弹窗
        showingCancelConfirm = true
    } else {
        dismiss()
    }
}

// 确认弹窗的选项：
// [放弃] [保存草稿] [继续编辑]
```

---

### 二、"我的"页面的操作逻辑

#### 2.1 三个标签页

```
[诗集]  [草稿]  [已发布]
```

**数据来源**：
```swift
// 诗集 Tab
poemManager.myCollection  // 本地数据

// 草稿 Tab
if authService.isAuthenticated {
    myDraftPoems  // 后端草稿
} else {
    poemManager.myDrafts  // 本地草稿
}

// 已发布 Tab
if authService.isAuthenticated {
    myPublishedPoems  // 后端数据
} else {
    []  // 未登录无数据
}
```

#### 2.2 诗歌卡片的操作

**长按菜单**：
```swift
.contextMenu {
    // 编辑按钮
    Button("编辑", systemImage: "pencil") {
        // 跳转到编辑页面？
        // 当前代码中没有实现
    }
    
    // 删除按钮
    Button("删除", role: .destructive) {
        showingDeleteAlert = true
        poemToDelete = poem
    }
}
```

#### 2.3 删除逻辑

```swift
func deletePoem(_ poem: Poem) {
    if authService.isAuthenticated && 
       (selectedTab == .drafts || selectedTab == .published) {
        // → 后端删除
        Task {
            try await poemService.deletePoem(id: poem.id)
            await loadUserPoems()
        }
    } else {
        // → 本地删除（诗集）
        poemManager.deletePoem(poem)
    }
}
```

#### 2.4 点击卡片

```swift
NavigationLink(destination: PoemDetailView(poem: poem)) {
    // 跳转到诗歌详情页
}
```

---

## ❌ 当前存在的问题

### 问题 1：数据存储混乱

**问题描述**：
- 草稿：登录前存本地，登录后存云端
- 诗集：永远存本地
- 已发布：永远存云端

**导致的困扰**：
- 用户不清楚数据存在哪里
- 登录前后数据不一致
- 本地和云端数据无法同步

---

### 问题 2：保存逻辑不一致

**问题描述**：

| 操作 | 保存位置 | 关闭页面 | 显示分享 |
|------|---------|---------|---------|
| 保存草稿 | 云端/本地 | ✅ | ❌ |
| 保存诗集 | 本地 | ❌ | ✅ |
| 发布广场 | 云端 | ✅ | ❌ |

**导致的困扰**：
- 点击"诗集"后不关闭页面，用户可能重复保存
- 只有"诗集"显示分享面板，其他方式没有
- 用户预期不一致

---

### 问题 3：编辑功能重复且不一致

**问题描述**：
目前有两个编辑入口，但实现不一致：

#### 入口 1：ProfileView 长按菜单
```swift
// ProfileView.swift
.contextMenu {
    Button("编辑", systemImage: "pencil") {
        // TODO: 没有实现，按钮无效
    }
}
```

#### 入口 2：PoemEditorDetailView 底部按钮
```swift
// PoemEditorDetailView.swift
Button("编辑") {
    isEditing = true  // ✅ 已实现
}
```

**导致的问题**：
- 用户不知道哪里可以编辑
- 两个编辑入口，一个有效，一个无效
- 编辑模式只在 PoemEditorDetailView 中，写诗页面的 `existingPoem` 参数未被使用

---

### 问题 4：草稿和诗集的区别不明确

**问题描述**：
- 草稿和诗集都是保存诗歌
- 用户不理解两者的区别
- 草稿应该是"未完成的"，诗集应该是"完成的"

**建议**：
- 草稿：未完成、可继续编辑
- 诗集：已完成、可分享

---

### 问题 5：删除确认不一致

**问题描述**：
```swift
// 删除时有弹窗确认
.alert("确认删除", isPresented: $showingDeleteAlert) {
    Button("取消", role: .cancel) {}
    Button("删除", role: .destructive) {
        deletePoem(poem)
    }
}

// 但"放弃"时也是删除，却没有明确告知
alert("确认取消") {
    Button("放弃", role: .destructive) {
        dismiss()  // 直接关闭，内容丢失
    }
}
```

---

### 问题 6：登录前后体验割裂

**登录前**：
- 草稿 → 本地
- 诗集 → 本地
- 发布 → 提示登录

**登录后**：
- 草稿 → 云端
- 诗集 → 还是本地（不统一）
- 发布 → 云端

**导致的困扰**：
- 登录前的本地数据无法迁移到云端
- 用户登录后看不到之前的草稿

---

## ✅ 重构方案建议

### 方案 A：简化为两种状态（推荐）

#### 1. 统一为两种状态
```
📝 草稿（未完成）
📚 已完成（可分享 + 可发布）
```

#### 2. 保存逻辑
```
[保存草稿]  [完成]
```

- **保存草稿**：
  - 保存到云端草稿（登录后）
  - 保存到本地草稿（未登录）
  - 关闭页面

- **完成**：
  - 保存到本地诗集
  - 显示后续操作弹窗：
    - 分享
    - 发布到广场（需登录）
    - 稍后再说（关闭）

#### 3. "我的"页面
```
[草稿]  [诗集]  [已发布]
```

- **草稿**：云端草稿（登录）+ 本地草稿（未登录）
- **诗集**：本地已完成的诗歌
- **已发布**：云端公开的诗歌

#### 4. 编辑功能
```swift
// 方案 A：使用现有的 PoemEditorDetailView（推荐）
// - 点击卡片 → PoemEditorDetailView → 点击底部"编辑"按钮
// - 移除 ProfileView 的长按编辑菜单（避免混淆）
// - 保持现有的编辑逻辑

// 方案 B：使用写诗页面编辑
// - 长按卡片 → 跳转到 DirectWritingView(existingPoem: poem)
// - 需要修改保存逻辑，区分"新建"和"更新"
```

---

### 方案 B：全部云端化

#### 1. 登录后全部存云端
- 草稿 → 云端
- 诗集 → 云端（is_public = false）
- 已发布 → 云端（is_public = true）

#### 2. 未登录时
- 提示用户登录
- 或临时存本地，登录后同步

#### 优点：
- 数据统一
- 可跨设备同步
- 不会数据丢失

#### 缺点：
- 强制登录
- 需要网络
- 实现复杂

---

## 🎯 推荐实施步骤

### Phase 1：修复编辑功能（优先）
1. **移除** ProfileView 的长按编辑菜单（避免混淆）
2. **保留** PoemEditorDetailView 的编辑按钮（已正常工作）
3. 统一编辑入口：点击卡片 → 详情页 → 编辑按钮

### Phase 2：统一保存逻辑
1. 移除"诗集"按钮，改为"完成"
2. "草稿"和"完成"都关闭页面
3. "完成"后显示后续操作弹窗

### Phase 3：优化删除确认
1. "放弃"改为"保存草稿"和"直接退出"
2. 删除操作统一使用 swipe 手势
3. 删除确认弹窗统一样式

### Phase 4：数据迁移（可选）
1. 登录时提示迁移本地数据
2. 将本地草稿上传到云端
3. 将本地诗集标记为"已完成"

---

## 📊 对比表格

| 功能 | 当前状态 | 方案 A | 方案 B |
|------|---------|--------|--------|
| 草稿存储 | 云端/本地 | 云端/本地 | 仅云端 |
| 诗集存储 | 本地 | 本地 | 云端 |
| 已发布存储 | 云端 | 云端 | 云端 |
| 编辑功能 | ❌ 缺失 | ✅ 实现 | ✅ 实现 |
| 保存按钮 | 3个 | 2个 | 2个 |
| 登录要求 | 可选 | 可选 | 必须 |
| 实现难度 | - | 中等 | 较难 |

---

## 🤔 需要讨论的问题

1. **是否保留"诗集"概念？**
   - 保留：3种状态（草稿、诗集、已发布）
   - 移除：2种状态（草稿、已发布）

2. **未登录用户的体验？**
   - 允许本地使用
   - 强制登录

3. **本地数据的处理？**
   - 登录时同步
   - 手动导出/导入
   - 不处理（自然淘汰）

4. **分享功能的触发时机？**
   - 完成时自动弹出
   - 手动点击分享按钮
   - 两种都支持

---

## 📝 下一步行动

请选择一个方案，我们开始重构！

### 选项 1：快速修复（30分钟）
- 移除无效的编辑按钮
- 统一删除操作（swipe 手势）
- 优化取消弹窗文案

### 选项 2：简化保存逻辑（2小时）
- 方案 A：两种状态（草稿 + 已完成）
- 统一保存按钮行为
- 完成后显示后续操作

### 选项 3：全面云端化（4小时）
- 方案 B：全部云端
- 数据迁移逻辑
- 跨设备同步

### 选项 4：自定义方案
- 你有其他想法？我们可以一起讨论！

---

## 🎯 我的建议

**第一步：快速修复**（现在就做）
1. 移除 ProfileView 的编辑菜单
2. 添加 swipe 删除手势
3. 优化"取消"弹窗

**第二步：简化逻辑**（下个版本）
1. 实施方案 A
2. 统一保存流程
3. 优化用户体验

**第三步：云端化**（长期规划）
1. 逐步迁移到云端
2. 实现数据同步
3. 跨设备支持

---

## 💬 请告诉我

1. **你觉得当前最大的问题是什么？**
   - 编辑入口混乱？
   - 保存逻辑复杂？
   - 数据存储不统一？

2. **你希望优先解决哪个问题？**
   - 快速修复明显的 bug？
   - 简化保存流程？
   - 统一数据存储？

3. **你对"草稿"和"诗集"的定位是什么？**
   - 草稿 = 未完成，诗集 = 已完成？
   - 草稿 = 私密，诗集 = 可分享？
   - 还是有其他理解？

回答这些问题，我就可以给你最合适的重构方案了！🚀

