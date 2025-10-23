# 🐛 代码审查报告

## 检查完成时间
2025-10-23

## 发现的严重问题

---

### ⚠️ 【严重】Bug #1: 笔名修改导致数据丢失

**影响等级**: 🔴 严重（数据丢失）

**问题描述**:
用户修改笔名后，所有已保存的诗歌会在下次保存时丢失。

**复现步骤**:
1. 用户使用笔名"诗人A"创建并保存5首诗
2. 在设置中将笔名修改为"诗人B"
3. 写一首新诗并保存（或任何触发savePoems()的操作）
4. 重启App
5. **结果**: 之前的5首诗全部丢失！

**根本原因**:
```swift
// PoemManager.swift:270-276
private func savePoems() {
    // 只保存当前用户的诗歌
    let myPoems = allPoems.filter { $0.authorName == currentUserName }
    
    if let encoded = try? JSONEncoder().encode(myPoems) {
        UserDefaults.standard.set(encoded, forKey: poemsKey)
    }
}
```

**问题分析**:
1. `currentUserName` 在初始化时从 UserDefaults 加载（第289行）
2. SettingsView 中通过 `@AppStorage("penName")` 可以修改笔名
3. 修改后，`PoemManager.currentUserName` **不会自动更新**
4. 但下次重启App时，会加载新笔名
5. 此时 `allPoems` 中的诗歌的 `authorName` 还是旧笔名
6. `savePoems()` 过滤条件匹配不上，诗歌丢失

**修复方案**:
```swift
// 方案1: 监听笔名变化，同步更新所有诗歌的 authorName
// 方案2: 不要用 authorName 过滤，改用设备唯一标识
// 方案3: 修改笔名时，同步更新所有诗歌的 authorName（推荐）
```

---

### ⚠️ 【中等】Bug #2: 示例诗歌管理混乱

**影响等级**: 🟡 中等（功能异常）

**问题描述**:
示例诗歌（Poem.examples）在首次启动后会丢失。

**根本原因**:
```swift
// PoemManager.swift:293-300
private func loadPublicPoems() {
    // 首次启动时，加载示例诗歌
    if UserDefaults.standard.bool(forKey: "has_loaded_public_poems") == false {
        allPoems.append(contentsOf: Poem.examples)
        UserDefaults.standard.set(true, forKey: "has_loaded_public_poems")
        savePoems()  // ⚠️ 这里会过滤掉示例诗歌！
    }
}
```

**问题流程**:
1. 首次启动，加载 `Poem.examples` 到 `allPoems`
2. 设置标记 `has_loaded_public_poems = true`
3. 调用 `savePoems()`
4. `savePoems()` 过滤条件: `authorName == currentUserName`
5. 示例诗歌的 `authorName` ≠ `currentUserName`，不会被保存
6. 下次启动时，标记已存在，不会再加载示例诗歌
7. **结果**: 示例诗歌丢失

**修复方案**:
```swift
// 方案1: 不保存示例诗歌，每次启动都重新加载（推荐）
// 方案2: 单独保存示例诗歌到另一个 key
// 方案3: 去掉 has_loaded_public_poems 标记，总是加载示例诗歌
```

---

### ⚠️ 【低】Bug #3: 重复检测没有检查作者

**影响等级**: 🟢 低（单用户场景无影响）

**问题描述**:
`saveToCollection()` 的重复检测没有验证 `authorName`。

**代码位置**:
```swift
// PoemManager.swift:114-119
let isDuplicate = allPoems.contains { existingPoem in
    existingPoem.id != poem.id && 
    existingPoem.title == poem.title && 
    existingPoem.content == poem.content && 
    existingPoem.inMyCollection
    // ⚠️ 缺少: && existingPoem.authorName == currentUserName
}
```

**潜在问题**:
理论上可能误判（如果 `allPoems` 中有其他用户的诗歌）。
但在当前单用户场景下，影响很小。

**修复方案**:
```swift
let isDuplicate = allPoems.contains { existingPoem in
    existingPoem.id != poem.id && 
    existingPoem.title == poem.title && 
    existingPoem.content == poem.content && 
    existingPoem.inMyCollection &&
    existingPoem.authorName == currentUserName  // 添加作者校验
}
```

---

## 其他发现

### ✅ 已关闭功能的遗留代码

**位置**: `ProfileView.swift:188-197`

```swift
if authService.isAuthenticated && (selectedTab == .drafts || selectedTab == .published) {
    // 后端删除
    Task {
        do {
            try await poemService.deletePoem(id: poem.id)
            await loadUserPoems()
        } catch {
            print("删除失败: \(error)")
        }
    }
}
```

**说明**:
V1 版本已关闭广场功能，`published` tab 显示"建设中"占位符。
这段删除逻辑实际上不会被触发，但保留也无妨（为V2做准备）。

---

## 修复优先级

### 🔴 必须立即修复:
1. **Bug #1: 笔名修改导致数据丢失** - 严重数据安全问题

### 🟡 建议修复:
2. **Bug #2: 示例诗歌管理混乱** - 影响用户体验

### 🟢 可选修复:
3. **Bug #3: 重复检测缺少作者校验** - 单用户场景下无影响

---

## 总结

### 核心问题:
`PoemManager` 的数据持久化逻辑依赖 `currentUserName`，但没有监听其变化。

### 根本原因:
设计时没有考虑"笔名可以修改"这个场景。

### 推荐方案:
1. 监听 UserDefaults 的 "penName" 变化
2. 当检测到变化时，同步更新所有本地诗歌的 `authorName`
3. 或者改用设备唯一标识（不依赖可变的笔名）

