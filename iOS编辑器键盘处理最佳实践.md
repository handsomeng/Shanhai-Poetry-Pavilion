# iOS 编辑器键盘处理最佳实践

> **作者**: AI 辅助开发  
> **日期**: 2025-10-29  
> **适用于**: SwiftUI + UIKit 混合开发

---

## 📝 问题描述

### 用户反馈
> "键盘一呼出来，整个文字全部都起飞了"

### 症状
- 键盘弹出时，标题、内容区、工具栏全部向上移动
- 整个页面被推上去，而不是只有编辑区滚动
- 用户体验不自然，不符合 iOS 原生应用习惯

---

## 🔍 根本原因分析

### ❌ 错误的架构设计

```
VStack {
    Title Field           ← 被推上去
    Divider
    UITextView           ← 被推上去
    Bottom Toolbar       ← 被推上去
}
.padding(.bottom, keyboardHeight)  ← 💥 问题所在
```

**问题**：
1. 使用外层 `.avoidKeyboard()` 修饰符
2. 给整个 `VStack` 添加 `padding(.bottom)`
3. 导致所有子视图都被推上去
4. 不符合 iOS 原生编辑体验

---

## ✅ 正确的架构设计

### 核心思想：让 UITextView 自己处理键盘

```
VStack {
    Title Field           ← 固定位置
    Divider               ← 固定位置
    UITextView            ← 自己滚动
      ├─ 监听键盘通知
      ├─ 调整 contentInset
      └─ 自动滚动到光标
    Bottom Toolbar        ← 固定位置
}
// 不需要外层处理键盘！
```

**关键点**：
- ✅ UITextView 本身就是 `UIScrollView`，天生支持滚动
- ✅ 只需要调整 `contentInset.bottom`
- ✅ UITextView 会自动滚动到光标位置
- ✅ 标题和工具栏保持固定

---

## 🛠️ 技术实现

### 1. UITextView 内部处理键盘

```swift
class Coordinator: NSObject, UITextViewDelegate {
    private var keyboardWillShowCancellable: AnyCancellable?
    private var keyboardWillHideCancellable: AnyCancellable?
    
    func setupKeyboardObservers(for textView: UITextView) {
        // 🔑 键盘即将显示
        keyboardWillShowCancellable = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return keyboardFrame.height
            }
            .sink { [weak textView] keyboardHeight in
                guard let textView = textView else { return }
                
                // 🎯 核心：调整 contentInset，为键盘留出空间
                var contentInset = textView.contentInset
                contentInset.bottom = keyboardHeight
                textView.contentInset = contentInset
                
                // 同时调整滚动条
                var scrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                scrollIndicatorInsets.bottom = keyboardHeight
                textView.verticalScrollIndicatorInsets = scrollIndicatorInsets
            }
        
        // 🔑 键盘即将隐藏
        keyboardWillHideCancellable = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak textView] _ in
                guard let textView = textView else { return }
                
                // 恢复原始 inset
                var contentInset = textView.contentInset
                contentInset.bottom = 0
                textView.contentInset = contentInset
                
                var scrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                scrollIndicatorInsets.bottom = 0
                textView.verticalScrollIndicatorInsets = scrollIndicatorInsets
            }
    }
    
    deinit {
        // 清理订阅，避免内存泄漏
        keyboardWillShowCancellable?.cancel()
        keyboardWillHideCancellable?.cancel()
    }
}
```

### 2. 在 makeUIView 中初始化

```swift
func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    
    // 样式设置
    textView.font = font
    textView.backgroundColor = .clear
    textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    
    // 键盘设置
    textView.keyboardDismissMode = .interactive  // 🔑 可以拖动关闭
    textView.autocorrectionType = .default
    textView.autocapitalizationType = .sentences
    
    // 🔑 关键：设置键盘监听
    context.coordinator.setupKeyboardObservers(for: textView)
    
    return textView
}
```

### 3. 外层不再需要处理键盘

```swift
// ✅ 正确用法
var body: some View {
    VStack(spacing: 0) {
        titleField
        Divider()
        UITextViewWrapper(text: $content)  // 自己处理键盘
        bottomToolbar
    }
}

// ❌ 错误用法（旧代码）
var body: some View {
    VStack(spacing: 0) {
        titleField
        Divider()
        UITextViewWrapper(text: $content)
            .avoidKeyboard()  // ← 删除这行！
        bottomToolbar
    }
}
```

---

## 🎯 方案优势

### 1. **原生体验**
- 使用 iOS 原生的键盘处理机制
- 流畅、可靠、零延迟
- 与系统应用行为一致

### 2. **职责单一**
- UITextView 自己管理滚动和键盘
- 外层 View 不干预
- 代码更清晰

### 3. **内存安全**
- 使用 `weak` 引用避免循环
- Combine 自动管理订阅生命周期
- `deinit` 时正确清理

### 4. **可维护性高**
- 所有逻辑集中在 `UITextViewWrapper` 中
- 不需要外层辅助文件（如 `KeyboardObserver`）
- 易于理解和修改

---

## 📋 完整修改清单

### 修改的文件

| 文件 | 修改内容 | 说明 |
|------|---------|------|
| **UITextViewWrapper.swift** | 添加键盘监听和 contentInset 调整 | 核心实现 |
| **PoemEditorView.swift** | 移除 `.avoidKeyboard()` | 不再需要 |
| **MyPoemDetailView.swift** | 移除 `.avoidKeyboard()` | 不再需要 |
| **KeyboardObserver.swift** | 删除整个文件 | 不再需要外层处理 |

### 代码行数对比

```
之前：
- UITextViewWrapper: 111 行（简单版）
- KeyboardObserver: 48 行（外层处理）
- PoemEditorView: 使用 .avoidKeyboard()
- MyPoemDetailView: 使用 .avoidKeyboard()
总计：159+ 行，逻辑分散

现在：
- UITextViewWrapper: 171 行（包含所有逻辑）
- 其他文件：移除键盘相关代码
总计：171 行，逻辑集中
```

---

## 🧪 测试检查清单

| 测试场景 | 预期行为 | 状态 |
|---------|---------|------|
| 短文本输入 | 光标始终可见 | ✅ |
| 长文本输入（超过屏幕） | UITextView 自动滚动，光标可见 | ✅ |
| 标题栏位置 | 键盘弹出时保持固定 | ✅ |
| 工具栏位置 | 键盘弹出时保持固定 | ✅ |
| 键盘弹出动画 | 平滑过渡，无跳动 | ✅ |
| 键盘收起动画 | 平滑恢复原状 | ✅ |
| 拖动键盘关闭 | 支持手势关闭（interactive） | ✅ |
| 内存管理 | 无泄漏，正确释放订阅 | ✅ |

---

## 📚 关键知识点

### 1. UITextView 的继承关系

```
UITextView
  └─ UIScrollView
      └─ UIView
```

**重要特性**：
- UITextView 本身就可以滚动
- 有 `contentInset` 和 `scrollIndicatorInsets` 属性
- 会自动滚动到光标位置

### 2. contentInset 的作用

```swift
// contentInset 是额外的内边距，不影响 contentSize
textView.contentInset.bottom = keyboardHeight

// 效果：
// - 内容可以滚动到键盘上方
// - 光标在键盘高度以下时，自动滚动
// - 不影响页面其他部分
```

### 3. Combine 的优势

```swift
// 传统方式（需要手动管理）
NotificationCenter.default.addObserver(
    self, 
    selector: #selector(keyboardWillShow), 
    name: UIResponder.keyboardWillShowNotification, 
    object: nil
)
// 需要在 deinit 中手动 removeObserver

// Combine 方式（自动管理）
keyboardWillShowCancellable = NotificationCenter.default
    .publisher(for: UIResponder.keyboardWillShowNotification)
    .sink { ... }
// 订阅者释放时自动取消订阅
```

---

## 🚀 与其他方案的对比

### 方案 A：SwiftUI TextEditor（不推荐）

```swift
TextEditor(text: $content)
    .padding(.bottom, keyboardHeight)
```

**问题**：
- ❌ 长文本卡顿
- ❌ 键盘处理不可靠
- ❌ 无法精确控制滚动
- ❌ 整个页面被推上去

### 方案 B：外层 ScrollView + 手动调整（复杂）

```swift
ScrollView {
    VStack {
        titleField
        TextEditor(text: $content)
        toolbar
    }
}
.padding(.bottom, keyboardHeight)
```

**问题**：
- ❌ 两层滚动（ScrollView + TextEditor）
- ❌ 滚动冲突
- ❌ 需要额外的 KeyboardObserver
- ❌ 代码分散，难以维护

### 方案 C：UITextView + 内部处理（推荐）✅

```swift
UITextViewWrapper(text: $content)
// 内部自己处理键盘，外层无需关心
```

**优势**：
- ✅ 原生流畅
- ✅ 职责单一
- ✅ 代码集中
- ✅ 易于维护

---

## 💡 最佳实践总结

### DO ✅

1. **让 UITextView 自己处理键盘**
   - 调整 `contentInset.bottom`
   - 信任系统的自动滚动

2. **使用 Combine 管理订阅**
   - 自动生命周期管理
   - 避免手动 removeObserver

3. **使用 weak 引用**
   - 避免循环引用
   - 保证内存安全

4. **集中逻辑**
   - 所有键盘相关代码放在一个文件
   - 外层不干预

### DON'T ❌

1. **不要给外层 View 加 padding**
   - 会导致整个页面移动
   - 不符合原生体验

2. **不要手动调用 scrollRectToVisible**
   - UITextView 会自动处理
   - 手动调用反而会冲突

3. **不要忘记清理订阅**
   - 始终在 deinit 中 cancel
   - 避免内存泄漏

4. **不要在多个地方处理键盘**
   - 职责不清晰
   - 容易冲突

---

## 🎓 学到的经验

### 1. 信任系统机制
- iOS 的 UITextView 已经非常成熟
- 不需要过度干预
- 使用原生机制是最好的选择

### 2. 职责分离
- 每个组件只做自己的事
- UITextView 处理滚动
- 外层只负责布局

### 3. 架构设计的重要性
- 正确的架构让问题迎刃而解
- 错误的架构会导致无尽的 workaround

### 4. 少即是多（Less is More）
- 删除 KeyboardObserver
- 删除 .avoidKeyboard() 修饰符
- 代码更少，但更优雅

---

## 📖 参考资料

- [Apple UITextView 文档](https://developer.apple.com/documentation/uikit/uitextview)
- [UIScrollView contentInset](https://developer.apple.com/documentation/uikit/uiscrollview/1619406-contentinset)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [SwiftUI UIViewRepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable)

---

## 🏆 总结

这个方案是 **iOS 文本编辑器键盘处理的最佳实践**。

**核心理念**：
> 让专业的组件做专业的事。UITextView 天生就会处理键盘，我们只需要告诉它键盘的高度即可。

**实现效果**：
- 原生流畅的编辑体验
- 标题和工具栏保持固定
- 只有编辑区滚动
- 光标始终可见

**代码质量**：
- 职责单一
- 逻辑集中
- 内存安全
- 易于维护

**这就是优雅的工程设计！** 🎯

