//
//  PoemEditorView.swift
//  山海诗馆
//
//  通用诗歌编辑器组件
//

import SwiftUI

/// 诗歌编辑器（通用组件）
struct PoemEditorView: View {
    
    @Binding var title: String
    @Binding var content: String
    
    let placeholder: String
    let showWordCount: Bool
    
    // 焦点管理
    @FocusState private var isContentFocused: Bool
    
    // 键盘高度监听
    @State private var keyboardHeight: CGFloat = 0
    
    init(
        title: Binding<String>,
        content: Binding<String>,
        placeholder: String = "在这里写下你的诗...",
        showWordCount: Bool = true
    ) {
        self._title = title
        self._content = content
        self.placeholder = placeholder
        self.showWordCount = showWordCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题输入
            titleField
            
            Divider()
                .padding(.horizontal, Spacing.lg)
            
            // 内容编辑区
            contentEditor
            
            // 底部工具栏
            if showWordCount {
                bottomToolbar
            }
        }
        .onAppear {
            startObservingKeyboard()
        }
    }
    
    // MARK: - Title Field
    
    private var titleField: some View {
        HStack {
            TextField("诗歌标题", text: Binding(
                get: { title },
                set: { newValue in
                    // 限制标题最多 30 字
                    if newValue.count <= 30 {
                        title = newValue
                    }
                }
            ))
            .font(Fonts.titleMedium())
            .foregroundColor(Colors.textInk)
            
            if !title.isEmpty {
                Text("\(title.count)/30")
                    .font(.system(size: 11, weight: .ultraLight))
                    .foregroundColor(title.count >= 30 ? Colors.error : Colors.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
    }
    
    // MARK: - Content Editor
    
    private var contentEditor: some View {
        ZStack(alignment: .topLeading) {
            // 占位符（在背景层，完全不影响交互）
            if content.isEmpty {
                Text(placeholder)
                    .font(Fonts.bodyPoem())
                    .foregroundColor(Colors.textSecondary.opacity(0.5))
                    .lineSpacing(8)  // 增加行间距
                    .padding(.horizontal, Spacing.lg + 4)
                    .padding(.vertical, Spacing.md + 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsHitTesting(false)
            }
            
            // 文本编辑器 - 根据键盘高度动态调整底部内边距
            TextEditor(text: $content)
                .font(Fonts.bodyPoem())
                .foregroundColor(Colors.textInk)
                .lineSpacing(8)  // 增加行间距
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, max(keyboardHeight - 100, 20))  // 🔑 根据键盘高度动态调整
                .scrollContentBackground(.hidden)
                .focused($isContentFocused)
                .scrollDismissesKeyboard(.interactively)
        }
        .background(Colors.white)
    }
    
    // MARK: - Bottom Toolbar
    
    private var bottomToolbar: some View {
        HStack {
            // 字数统计
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.system(size: 12))
                Text("\(content.count) 字")
                    .font(Fonts.footnote())
            }
            .foregroundColor(Colors.textSecondary)
            
            Spacer()
            
            // 行数统计
            HStack(spacing: 4) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 12))
                Text("\(lineCount) 行")
                    .font(Fonts.footnote())
            }
            .foregroundColor(Colors.textSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Computed Properties
    
    private var lineCount: Int {
        content.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count
    }
    
    // MARK: - Keyboard Handling
    
    /// 开始监听键盘事件
    private func startObservingKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }
}

// MARK: - Preview

#Preview("诗歌编辑器") {
    struct PreviewWrapper: View {
        @State private var title = "城市夜晚"
        @State private var content = """
        路灯一盏盏亮起
        像是在点名
        
        却没有人
        应答
        """
        
        var body: some View {
            PoemEditorView(
                title: $title,
                content: $content
            )
        }
    }
    
    return PreviewWrapper()
}


