# PRD: 草稿系统优化

> **版本**: V1.0  
> **日期**: 2025-10-26  
> **状态**: 待开发

---

## 🎯 问题分析

### 当前问题

用户反馈：
1. ❌ **保存时会保存两个诗歌**
2. ❌ **不是真正的"自动保存"**

### 问题根源

#### 1. 自动保存逻辑有误

**当前代码（DirectWritingView.swift）：**

```swift
// 每30秒调用一次
private func autoSaveDraft() {
    guard !content.isEmpty else { return }
    guard !hasSaved else { return }
    
    let draft = poemManager.createDraft(...)  // ❌ 每次都创建新草稿！
    poemManager.savePoem(draft)               // ❌ 保存新草稿
}
```

**问题：**
- `createDraft()` 会 `allPoems.append(poem)` ——每次都创建一个**新的草稿**
- 如果用户写诗5分钟（30秒 × 10次），会创建 **10个草稿**！
- 用户在草稿 Tab 看到多个重复的草稿

#### 2. 手动保存逻辑混乱

**当前代码：**

```swift
// 点击右上角"保存"按钮
private func saveToCollection() {
    let newPoem = Poem(
        title: title,
        content: content,
        inMyCollection: true,  // ✅ 保存到诗集
        inSquare: false
    )
    poemManager.saveToCollection(newPoem)
}
```

**结果：**
- 自动保存已经创建了 **N个草稿**（每30秒一个）
- 手动保存又创建了 **1个诗集作品**
- 用户看到：**草稿Tab有N个重复草稿 + 诗集Tab有1个作品**
- **总共N+1个诗歌！**

#### 3. 草稿未自动清理

**当前逻辑：**
- 保存到诗集后，之前的草稿没有被删除
- 导致草稿Tab有很多"已完成"的草稿

---

## ✅ 解决方案

### 核心原则

1. **一次写作 = 一个草稿 ID**：整个写作过程中，只使用同一个草稿 ID
2. **真正的自动保存**：不断更新同一个草稿，而不是创建新的
3. **保存到诗集时清理草稿**：避免重复

---

## 📝 详细设计

### 1. 初始化时创建唯一草稿 ID

```swift
struct DirectWritingView: View {
    // 草稿 ID（整个写作过程使用同一个 ID）
    @State private var draftId: String = UUID().uuidString
    
    init(existingPoem: Poem? = nil) {
        self.existingPoem = existingPoem
        // 如果是编辑现有诗歌，使用现有ID
        if let poem = existingPoem {
            _draftId = State(initialValue: poem.id)
        }
    }
}
```

### 2. 自动保存逻辑（更新而非创建）

**修改前：**
```swift
private func autoSaveDraft() {
    let draft = poemManager.createDraft(...)  // ❌ 创建新草稿
    poemManager.savePoem(draft)               // ❌ 保存新草稿
}
```

**修改后：**
```swift
private func autoSaveDraft() {
    guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    
    // 检查草稿是否已存在
    if let existingDraft = poemManager.getPoem(by: draftId) {
        // ✅ 更新现有草稿
        var updatedDraft = existingDraft
        updatedDraft.title = title
        updatedDraft.content = content
        updatedDraft.updatedAt = Date()
        poemManager.savePoem(updatedDraft)
        print("📝 [自动保存] 已更新草稿: \(draftId)")
    } else {
        // ✅ 首次创建草稿（使用固定的 draftId）
        let draft = Poem(
            id: draftId,  // 使用固定ID
            title: title,
            content: content,
            authorName: poemManager.currentUserName,
            userId: poemManager.currentUserId,
            tags: [],
            writingMode: .direct,
            inMyCollection: false,  // 草稿状态
            inSquare: false
        )
        poemManager.allPoems.append(draft)
        poemManager.savePoem(draft)
        print("📝 [自动保存] 已创建草稿: \(draftId)")
    }
}
```

### 3. 手动保存到诗集（清理草稿）

**修改前：**
```swift
private func saveToCollection() {
    let newPoem = Poem(
        title: title,
        content: content,
        inMyCollection: true,
        inSquare: false
    )
    poemManager.saveToCollection(newPoem)
}
```

**修改后：**
```swift
private func saveToCollection() {
    // 1. 检查是否有对应的草稿
    if let existingDraft = poemManager.getPoem(by: draftId), !existingDraft.inMyCollection {
        // ✅ 方案A：将草稿转为诗集作品（保持同一个ID）
        var poemToSave = existingDraft
        poemToSave.title = title.isEmpty ? "无标题" : title
        poemToSave.content = content
        poemToSave.inMyCollection = true  // 转为诗集
        poemToSave.updatedAt = Date()
        
        let saved = poemManager.saveToCollection(poemToSave)
        if !saved {
            ToastManager.shared.showInfo("这首诗已经在诗集中了")
            return
        }
    } else {
        // ✅ 没有草稿，直接创建新诗歌
        let newPoem = Poem(
            title: title.isEmpty ? "无标题" : title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .direct,
            inMyCollection: true,
            inSquare: false
        )
        
        let saved = poemManager.saveToCollection(newPoem)
        if !saved {
            ToastManager.shared.showInfo("这首诗已经在诗集中了")
            return
        }
    }
    
    hasSaved = true
    ToastManager.shared.showSuccess("已保存")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        dismiss()
    }
}
```

### 4. 取消时的逻辑（保留草稿）

**保持不变：**
- 用户点击"取消"时，如果有内容，弹窗确认
- 选项：
  - "放弃"：不保存，直接退出
  - "自动保存草稿"：保存草稿后退出（使用 `autoSaveDraft()`）
  - "继续编辑"：返回编辑

### 5. PoemManager 新增方法

```swift
// 在 PoemManager.swift 中添加

/// 更新诗歌（如果不存在则创建）
func updateOrCreatePoem(_ poem: Poem) {
    if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
        // 更新现有诗歌
        var updatedPoem = poem
        updatedPoem.updatedAt = Date()
        allPoems[index] = updatedPoem
    } else {
        // 创建新诗歌
        var newPoem = poem
        newPoem.updatedAt = Date()
        allPoems.append(newPoem)
    }
    savePoems()
}
```

---

## 🎬 用户体验流程

### 场景1：写诗并保存到诗集

```
1. 用户打开写诗页面
   → 创建唯一草稿ID: draft-001
   
2. 用户输入内容
   第30秒 → 自动保存草稿 draft-001（创建）
   第60秒 → 自动保存草稿 draft-001（更新）
   第90秒 → 自动保存草稿 draft-001（更新）
   
3. 用户点击"保存"
   → 将草稿 draft-001 转为诗集作品
   → 标记 inMyCollection = true
   → 删除草稿状态
   → Toast: "已保存"
   → 关闭页面
   
结果：
✅ 诗集Tab：1首诗（draft-001）
✅ 草稿Tab：0首草稿
```

### 场景2：写诗但中途放弃

```
1. 用户打开写诗页面
   → 创建唯一草稿ID: draft-002
   
2. 用户输入内容
   第30秒 → 自动保存草稿 draft-002（创建）
   第60秒 → 自动保存草稿 draft-002（更新）
   
3. 用户点击"取消" → 选择"自动保存草稿"
   → 保存草稿 draft-002（最终更新）
   → Toast: "已自动保存到草稿"
   → 关闭页面
   
结果：
✅ 诗集Tab：0首诗
✅ 草稿Tab：1首草稿（draft-002）
```

### 场景3：从草稿继续编辑

```
1. 用户从草稿Tab点击草稿
   → 打开写诗页面（预填充内容）
   → 使用草稿的ID: draft-002
   
2. 用户继续编辑
   第30秒 → 自动保存草稿 draft-002（更新）
   第60秒 → 自动保存草稿 draft-002（更新）
   
3. 用户点击"保存"
   → 将草稿 draft-002 转为诗集作品
   → 标记 inMyCollection = true
   → Toast: "已保存"
   → 关闭页面
   
结果：
✅ 诗集Tab：1首诗（draft-002，从草稿转来）
✅ 草稿Tab：0首草稿（draft-002已转为诗集）
```

---

## 🔧 需要修改的文件

### 1. DirectWritingView.swift
- 添加 `@State private var draftId: String`
- 修改 `init()` 方法
- 修改 `autoSaveDraft()` 方法
- 修改 `saveToCollection()` 方法

### 2. ThemeWritingView.swift
- 同 DirectWritingView.swift

### 3. MimicWritingView.swift
- 同 DirectWritingView.swift

### 4. PoemManager.swift
- 添加 `updateOrCreatePoem()` 方法（可选，可以直接使用现有的 `savePoem()`）

---

## ✅ 验收标准

### 功能测试

1. ✅ **写诗并保存**
   - 草稿Tab：0首草稿
   - 诗集Tab：1首诗

2. ✅ **写诗并放弃（保存草稿）**
   - 草稿Tab：1首草稿
   - 诗集Tab：0首诗

3. ✅ **从草稿继续编辑并保存**
   - 草稿Tab：0首草稿（原草稿已转为诗集）
   - 诗集Tab：1首诗

4. ✅ **自动保存不会创建多个草稿**
   - 写诗5分钟，草稿Tab只有1首草稿（不是N首）

5. ✅ **保存后草稿自动清理**
   - 保存到诗集后，草稿Tab不再显示该草稿

---

## 🎯 总结

### 核心改进

1. **一个写作流程 = 一个草稿ID** ✅
2. **自动保存 = 更新草稿（而非创建新草稿）** ✅
3. **保存到诗集 = 草稿转诗集（而非创建新诗+保留草稿）** ✅

### 用户感知

- ✅ 不再有重复的草稿
- ✅ 草稿Tab干净整洁
- ✅ 真正的"自动保存"体验（类似 Notion）
- ✅ 保存逻辑更符合直觉

