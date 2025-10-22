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
    }
    
    // MARK: - Title Field
    
    private var titleField: some View {
        TextField("诗歌标题", text: $title)
            .font(Fonts.titleMedium())
            .foregroundColor(Colors.textInk)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Colors.white)
    }
    
    // MARK: - Content Editor
    
    private var contentEditor: some View {
        ZStack(alignment: .topLeading) {
            // 占位符
            if content.isEmpty {
                Text(placeholder)
                    .font(Fonts.bodyPoem())
                    .foregroundColor(Colors.textSecondary.opacity(0.5))
                    .padding(.horizontal, Spacing.lg + 5)
                    .padding(.vertical, Spacing.md + 8)
                    .allowsHitTesting(false)
            }
            
            // 文本编辑器
            TextEditor(text: $content)
                .font(Fonts.bodyPoem())
                .foregroundColor(Colors.textInk)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .scrollContentBackground(.hidden)
                .background(Colors.white)
        }
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


