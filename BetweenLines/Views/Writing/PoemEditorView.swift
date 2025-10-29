//
//  PoemEditorView.swift
//  山海诗馆
//
//  通用诗歌编辑器组件 - 全新纯 UIKit 实现
//

import SwiftUI

/// 诗歌编辑器（通用组件）
/// 使用纯 UIKit 实现，参考 iOS 备忘录
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
            // 使用全新的纯 UIKit 编辑器
            PoemTextEditor(
                title: $title,
                content: $content,
                placeholder: placeholder
            )
            
            // 底部工具栏（可选）
            if showWordCount {
                bottomToolbar
            }
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


