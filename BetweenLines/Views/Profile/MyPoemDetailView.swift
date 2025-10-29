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
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    let poem: Poem
    let isDraft: Bool // 是否是草稿
    
    // 编辑状态
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @FocusState private var focusedField: Field?
    
    // UI 状态
    @State private var showingActionsMenu = false
    @State private var showingDeleteAlert = false
    @State private var showingShareView = false
    
    // AI点评状态
    @State private var showingAIComment = false
    @State private var isLoadingAIComment = false
    @State private var aiCommentText: String = ""
    
    enum Field {
        case title
        // content 现在使用 UITextViewWrapper，不需要焦点管理
    }
    
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
                                showingActionsMenu = false
                                sharePoem()
                            },
                            onEdit: {
                                showingActionsMenu = false
                                enterEditMode()
                            },
                            onAIComment: {
                                showingActionsMenu = false
                                requestAIComment()
                            },
                            onCopy: {
                                showingActionsMenu = false
                                copyPoem()
                            },
                            onDelete: {
                                showingActionsMenu = false
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
        .sheet(isPresented: $showingAIComment) {
            AICommentSheet(
                comment: aiCommentText,
                isLoading: isLoadingAIComment,
                onDismiss: {
                    showingAIComment = false
                }
            )
        }
        .fullScreenCover(isPresented: $showingShareView) {
            PoemShareView(poem: poem)
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
                .frame(height: Spacing.lg) // 缩短留白
            
            // 底部信息
            poemMetadata
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .onTapGesture(count: 2) {
            // 🔑 双击进入编辑模式
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                enterEditMode()
            }
        }
    }
    
    // MARK: - Editing View (编辑模式)
    
    private var editingView: some View {
        VStack(spacing: 0) {
            // 标题输入
            TextField("标题（选填）", text: $editedTitle)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundColor(Colors.textInk)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.md)
                .focused($focusedField, equals: .title)
            
            Divider()
                .padding(.horizontal, Spacing.lg)
            
            // 内容输入 - 使用 UITextViewWrapper（自己处理键盘）
            UITextViewWrapper(
                text: $editedContent,
                placeholder: "在这里编辑你的诗...",
                font: UIFont.systemFont(ofSize: 18),
                textColor: UIColor(Colors.textInk),
                placeholderColor: UIColor(Colors.textSecondary.opacity(0.5))
            )
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
            
            Spacer()
                .frame(height: 16)
            
            // 双击编辑提示
            HStack(spacing: 4) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 11))
                Text("双击屏幕快速编辑")
                    .font(.system(size: 11, weight: .light))
            }
            .foregroundColor(Colors.textTertiary.opacity(0.6))
        }
    }
    
    // MARK: - Actions
    
    /// 进入编辑模式
    private func enterEditMode() {
        // 重置编辑内容为当前诗歌内容
        editedTitle = poem.title
        editedContent = poem.content
        
        // 进入编辑状态
        isEditing = true
        
        // UITextViewWrapper 会自动处理焦点，无需手动设置
    }
    
    /// 取消编辑
    private func cancelEditing() {
        focusedField = nil // 收起键盘
        isEditing = false
        // 恢复原始内容
        editedTitle = poem.title
        editedContent = poem.content
    }
    
    /// 保存编辑
    private func saveEditing() {
        focusedField = nil // 收起键盘
        
        var updatedPoem = poem
        updatedPoem.title = editedTitle
        updatedPoem.content = editedContent
        updatedPoem.updatedAt = Date()
        
        // 如果是草稿，保存时转为诗集
        if isDraft {
            updatedPoem.inMyCollection = true  // 将草稿转为诗集
            let saved = poemManager.saveToCollection(updatedPoem)
            if saved {
                toastManager.showSuccess("已保存到诗集")
                // 延迟返回，让用户看到提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss() // 返回诗集页面
                }
            } else {
                toastManager.showInfo("这首诗已经在诗集中了")
            }
        } else {
            // 如果已经是诗集作品，只是更新内容
            poemManager.savePoem(updatedPoem)
            toastManager.showSuccess("保存成功")
        }
        
        isEditing = false
    }
    
    /// 分享诗歌
    private func sharePoem() {
        showingShareView = true
    }
    
    /// 请求AI点评
    private func requestAIComment() {
        // 检查权限
        if !subscriptionManager.canUseAIComment() {
            let remaining = subscriptionManager.remainingAIComments()
            if remaining == 0 {
                toastManager.showInfo("今日AI点评次数已用完，明天再来吧")
            } else {
                toastManager.showInfo("今日还剩 \(remaining) 次AI点评")
            }
            return
        }
        
        // 显示加载状态
        isLoadingAIComment = true
        aiCommentText = ""
        showingAIComment = true
        
        // 调用AI服务
        Task {
            do {
                let comment = try await AIService.shared.getPoemComment(content: poem.content)
                await MainActor.run {
                    aiCommentText = comment
                    isLoadingAIComment = false
                    
                    // 保存点评到诗歌
                    var updatedPoem = poem
                    updatedPoem.aiComment = comment
                    poemManager.addAIComment(to: updatedPoem, comment: comment)
                    
                    // 消耗次数
                    subscriptionManager.useAIComment()
                }
            } catch {
                await MainActor.run {
                    isLoadingAIComment = false
                    showingAIComment = false
                    
                    if let appError = error as? AppError {
                        toastManager.showError(appError.localizedDescription)
                    } else {
                        toastManager.showError("AI点评失败，请稍后再试")
                    }
                }
            }
        }
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
