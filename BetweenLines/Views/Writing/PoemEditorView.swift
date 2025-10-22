//
//  PoemEditorView.swift
//  山海诗馆
//
//  通用诗歌编辑器组件
//

import SwiftUI
import Combine

/// 诗歌编辑器（通用组件）
struct PoemEditorView: View {
    
    @Binding var title: String
    @Binding var content: String
    
    let placeholder: String
    let showWordCount: Bool
    
    // 监听键盘事件
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
            // 监听键盘显示/隐藏事件
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
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
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        // 占位符
                        if content.isEmpty {
                            Text(placeholder)
                                .font(Fonts.bodyPoem())
                                .foregroundColor(Colors.textSecondary.opacity(0.5))
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .allowsHitTesting(false)
                        }
                        
                        // 文本编辑器 - 自动适应键盘
                        TextEditor(text: $content)
                            .font(Fonts.bodyPoem())
                            .foregroundColor(Colors.textInk)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: geometry.size.height)
                            .background(Colors.white)
                            .id("editor")
                    }
                }
                .onChange(of: content) { _ in
                    // 内容变化时，确保编辑器可见
                    withAnimation {
                        proxy.scrollTo("editor", anchor: .bottom)
                    }
                }
            }
        }
        .background(Colors.white)
        // 根据键盘高度调整底部 padding，确保输入区域不被遮挡
        .padding(.bottom, keyboardHeight > 0 ? max(0, keyboardHeight - 200) : 0)
        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
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


