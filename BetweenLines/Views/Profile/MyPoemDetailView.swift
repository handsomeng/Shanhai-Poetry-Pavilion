//
//  MyPoemDetailView.swift
//  山海诗馆
//
//  诗歌详情页：支持查看、编辑、复制、删除
//  - 默认只读模式，点击 ⋯ 菜单可选择操作
//  - 编辑模式：显示取消和完成按钮
//

import SwiftUI

struct MyPoemDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var toastManager = ToastManager.shared
    
    let poem: Poem
    let isDraft: Bool // 是否是草稿
    
    // 编辑状态
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    
    // UI 状态
    @State private var showingActionsMenu = false
    @State private var showingDeleteAlert = false
    
    init(poem: Poem, isDraft: Bool = false) {
        self.poem = poem
        self.isDraft = isDraft
        _editedTitle = State(initialValue: poem.title)
        _editedContent = State(initialValue: poem.content)
    }
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            // 主内容
            if isEditing {
                editingView
            } else {
                readOnlyView
            }
            
            // 操作菜单（右上角）
            if showingActionsMenu {
                Color.black.opacity(0.001) // 透明遮罩，用于点击关闭
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showingActionsMenu = false
                        }
                    }
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()
                        PoemActionsMenu(
                            onShare: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showingActionsMenu = false
                                }
                                sharePoem()
                            },
                            onEdit: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showingActionsMenu = false
                                }
                                enterEditMode()
                            },
                            onCopy: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showingActionsMenu = false
                                }
                                copyPoem()
                            },
                            onDelete: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showingActionsMenu = false
                                }
                                showingDeleteAlert = true
                            }
                        )
                        .padding(.trailing, 8) // 距离右边缘稍微一点距离
                        .padding(.top, 8) // 紧贴按钮下方
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if isEditing {
                // 编辑模式：取消 + 完成
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        cancelEditing()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveEditing()
                    }
                    .foregroundColor(Colors.accentTeal)
                }
            } else {
                // 只读模式：⋯ 菜单
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showingActionsMenu.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Colors.textInk)
                            .frame(width: 44, height: 32)
                    }
                }
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deletePoem()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后无法恢复")
        }
    }
    
    // MARK: - Read-Only View (只读模式)
    
    private var readOnlyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 标题
                if !poem.title.isEmpty {
                    Text(poem.title)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .padding(.top, Spacing.lg)
                }
                
                // 正文
                Text(poem.content)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                    .frame(height: Spacing.xl)
                
                // 底部信息
                poemMetadata
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    // MARK: - Editing View (编辑模式)
    
    private var editingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 标题输入
                TextField("标题（选填）", text: $editedTitle)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .padding(.top, Spacing.lg)
                
                // 内容输入
                TextEditor(text: $editedContent)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .lineSpacing(8)
                    .frame(minHeight: 300)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    // MARK: - Poem Metadata (底部信息)
    
    private var poemMetadata: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Divider()
                .background(Colors.divider)
            
            // 第 X 首诗
            Text("第 \(poemManager.myCollection.count) 首诗")
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Colors.textTertiary)
            
            // 称号 · 作者名
            HStack(spacing: 4) {
                Text(poemManager.currentPoetTitle.displayName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Colors.textSecondary)
                
                Text("·")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(Colors.textTertiary)
                
                Text(poem.authorName)
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundColor(Colors.textTertiary)
            }
            
            // 创建时间
            Text(poem.createdAt, style: .date)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Colors.textTertiary)
        }
    }
    
    // MARK: - Actions
    
    /// 进入编辑模式
    private func enterEditMode() {
        isEditing = true
        // 重置编辑内容为当前诗歌内容
        editedTitle = poem.title
        editedContent = poem.content
    }
    
    /// 取消编辑
    private func cancelEditing() {
        isEditing = false
        // 恢复原始内容
        editedTitle = poem.title
        editedContent = poem.content
    }
    
    /// 保存编辑
    private func saveEditing() {
        var updatedPoem = poem
        updatedPoem.title = editedTitle
        updatedPoem.content = editedContent
        updatedPoem.updatedAt = Date()
        
        poemManager.savePoem(updatedPoem)
        toastManager.showSuccess("保存成功")
        
        isEditing = false
    }
    
    /// 分享诗歌
    private func sharePoem() {
        // 🚧 TODO: 实现分享功能（待开发）
        toastManager.showInfo("分享功能开发中...")
    }
    
    /// 复制诗歌
    private func copyPoem() {
        var content = ""
        if !poem.title.isEmpty {
            content += poem.title + "\n\n"
        }
        content += poem.content
        
        UIPasteboard.general.string = content
        toastManager.showSuccess("已复制")
    }
    
    /// 删除诗歌
    private func deletePoem() {
        poemManager.deletePoem(poem)
        toastManager.showSuccess("已删除")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyPoemDetailView(
            poem: Poem(
                title: "夜思",
                content: "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡",
                authorName: "诗人",
                tags: [],
                writingMode: .direct
            )
        )
    }
}
