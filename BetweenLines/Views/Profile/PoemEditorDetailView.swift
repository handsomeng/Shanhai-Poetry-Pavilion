//
//  PoemEditorDetailView.swift
//  山海诗馆
//
//  诗集/草稿的编辑详情页
//  ⚠️ 已简化：移除了发布到广场和AI点评功能
//

import SwiftUI

struct PoemEditorDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var toastManager = ToastManager.shared
    // @StateObject private var subscriptionManager = SubscriptionManager.shared // 🔴 已废弃
    
    @State var poem: Poem
    
    // 编辑状态
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    
    // 🔴 旧代码：分享和AI功能已废弃
    // @State private var showingShareSheet = false
    // @State private var showingAIComment = false
    // @State private var aiComment = ""
    // @State private var isLoadingAI = false
    // @State private var showingSubscription = false
    
    // 键盘状态
    @State private var isKeyboardVisible = false
    
    init(poem: Poem) {
        self._poem = State(initialValue: poem)
        self._editedTitle = State(initialValue: poem.title)
        self._editedContent = State(initialValue: poem.content)
    }
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isEditing {
                    // 编辑模式
                    PoemEditorView(
                        title: $editedTitle,
                        content: $editedContent,
                        showWordCount: !isKeyboardVisible
                    )
                } else {
                    // 查看模式
                    viewModeContent
                }
                
                // 底部按钮（键盘隐藏时显示）
                if !isKeyboardVisible {
                    bottomActions
                }
            }
        }
        .navigationTitle(isEditing ? "编辑诗歌" : "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing) // 编辑时隐藏返回按钮
        .toolbar {
            if isEditing {
                // 编辑模式工具栏
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        cancelEditing()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
                
                if hasChanges {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("保存") {
                            saveChanges()
                        }
                        .foregroundColor(Colors.accentTeal)
                    }
                }
            }
        }
        /* 🔴 旧代码：分享和AI功能已废弃
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(poem: poem)
        }
        .sheet(isPresented: $showingAIComment) {
            AICommentSheet(comment: aiComment, isLoading: isLoadingAI)
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        */
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    // MARK: - View Mode Content
    
    private var viewModeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // 标题
                if !poem.title.isEmpty {
                    Text(poem.title)
                        .font(Fonts.h2())
                        .foregroundColor(Colors.textInk)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 正文
                Text(poem.content)
                    .font(Fonts.bodyPoem())
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 元信息
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(poem.formattedDate)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                    
                    Text("创作方式：\(poem.writingMode.rawValue)")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                    
                    if let reference = poem.referencePoem {
                        Text("参考：\(reference)")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                .padding(.top, Spacing.md)
            }
            .padding(Spacing.lg)
            .padding(.bottom, 100) // 为底部按钮留出空间
        }
        .background(Colors.white)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        VStack(spacing: Spacing.xs) {
            // 编辑按钮（全宽）
            Button(action: {
                isEditing = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("编辑")
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.white)
                .cornerRadius(CornerRadius.medium)
            }
            .scaleButtonStyle()
            
            /* 🔴 旧代码：发布到广场和AI点评功能已废弃
            HStack(spacing: Spacing.xs) {
                // 发布到广场按钮
                if poem.squareId != nil {
                    // 已发布状态（不可点击）
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("已发布广场")
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.white.opacity(0.5))
                    .cornerRadius(CornerRadius.medium)
                } else {
                    // 未发布，可以发布
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("发布到广场")
                        }
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.accentTeal)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Colors.white)
                        .cornerRadius(CornerRadius.medium)
                    }
                    .scaleButtonStyle()
                }
            }
            
            // AI 点评按钮（全宽）
            Button(action: requestAIComment) {
                HStack {
                    if isLoadingAI {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Colors.accentTeal)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isLoadingAI ? "AI 点评中..." : "AI 点评")
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.accentTeal)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.white)
                .cornerRadius(CornerRadius.medium)
            }
            .disabled(isLoadingAI)
            .scaleButtonStyle()
            */
        }
        .padding(Spacing.md)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Computed Properties
    
    private var hasChanges: Bool {
        editedTitle != poem.title || editedContent != poem.content
    }
    
    // MARK: - Actions
    
    private func cancelEditing() {
        // 恢复原始内容
        editedTitle = poem.title
        editedContent = poem.content
        isEditing = false
    }
    
    private func saveChanges() {
        var updatedPoem = poem
        updatedPoem.title = editedTitle
        updatedPoem.content = editedContent
        updatedPoem.updatedAt = Date()
        
        poemManager.savePoem(updatedPoem)
        poem = updatedPoem
        
        toastManager.showSuccess("保存成功")
        isEditing = false
    }
    
    /* 🔴 旧代码：AI点评功能已废弃
    private func requestAIComment() {
        guard !poem.content.isEmpty else { return }
        
        // 检查是否有权限使用 AI 点评
        if !subscriptionManager.canUseAIComment() {
            let remaining = subscriptionManager.remainingAIComments()
            toastManager.showError("今日 AI 点评次数已用完（\(remaining)/3）")
            
            // 延迟显示订阅页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingSubscription = true
            }
            return
        }
        
        isLoadingAI = true
        Task {
            do {
                let comment = try await AIService.shared.getPoemComment(content: poem.content)
                await MainActor.run {
                    aiComment = comment
                    isLoadingAI = false
                    showingAIComment = true
                    
                    // 使用一次 AI 点评
                    subscriptionManager.useAIComment()
                }
            } catch {
                await MainActor.run {
                    isLoadingAI = false
                    toastManager.showError("AI 点评失败，请重试")
                }
            }
        }
    }
    */
    
    // MARK: - Keyboard Observers
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = true
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PoemEditorDetailView(poem: Poem.example)
    }
}

