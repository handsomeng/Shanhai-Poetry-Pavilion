//
//  ThemeWritingView.swift
//  山海诗馆
//
//  主题写诗模式：AI 生成创作主题，用户根据主题创作
//

import SwiftUI

struct ThemeWritingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    
    // AI 生成的主题和引导
    @State private var aiTheme: String = ""
    @State private var aiGuidance: String = "" // 创作引导
    @State private var isLoadingTheme = false
    
    // 创作内容
    @State private var title = ""
    @State private var content = ""
    @State private var currentPoem: Poem?
    @State private var showingShareSheet = false
    @State private var isKeyboardVisible = false
    @State private var showingSubscription = false
    @State private var isPublishing = false
    @State private var showLoginSheet = false
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            if isLoadingTheme {
                loadingView
            } else if aiTheme.isEmpty {
                generatePromptView
            } else {
                writingView
            }
        }
        .navigationTitle("主题写诗")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    if content.isEmpty && title.isEmpty {
                        dismiss()
                    } else {
                        // 有内容时，显示保存草稿确认
                        showSaveAlert()
                    }
                }
            }
            
            if !aiTheme.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("换主题") {
                        generateTheme()
                    }
                    .disabled(isLoadingTheme)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let poem = currentPoem {
                ShareSheet(poem: poem)
            }
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .onAppear {
            // 监听键盘
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
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: Spacing.xl) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Colors.accentTeal)
            
            Text("AI 正在生成创作主题...")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Generate Prompt View
    
    private var generatePromptView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            VStack(spacing: Spacing.lg) {
                Text("💡")
                    .font(.system(size: 64))
                
                Text("主题写诗")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                    .multilineTextAlignment(.center)
                
                Text("AI 为你推荐创作主题和角度\n围绕主题展开你的创作")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Button(action: handleStart) {
                Text("开始创作")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.accentTeal)
                    .cornerRadius(CornerRadius.medium)
            }
            .scaleButtonStyle()
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    // MARK: - Writing View
    
    private var writingView: some View {
        VStack(spacing: 0) {
            // 顶部主题卡片（精简）
            themeCard
            
            // 编辑器
            PoemEditorView(
                title: $title,
                content: $content,
                placeholder: "围绕主题「\(aiTheme)」，写下你的诗...",
                showWordCount: !isKeyboardVisible
            )
            
            // 底部按钮
            if !isKeyboardVisible {
                bottomButtons
            }
        }
    }
    
    // MARK: - Theme Card
    
    private var themeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 头部：主题标题
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("创作主题")
                        .font(Fonts.captionSmall())
                        .foregroundColor(Colors.textSecondary)
                    
                    Text(aiTheme)
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                }
                
                Spacer()
                
                Text("AI 推荐")
                    .font(Fonts.captionSmall())
                    .foregroundColor(Colors.accentTeal)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Colors.accentTeal.opacity(0.1))
                    .cornerRadius(CornerRadius.small)
            }
            
            // 引导内容
            if !aiGuidance.isEmpty {
                Text(aiGuidance)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.md)
        .background(Colors.backgroundCream.opacity(0.5))
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            // 保存草稿
            Button(action: saveDraft) {
                VStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                    Text("草稿")
                        .font(Fonts.caption())
                }
                .foregroundColor(Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            .disabled(content.isEmpty)
            
            // 保存到诗集
            Button(action: saveToCollection) {
                VStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 20))
                    Text("诗集")
                        .font(Fonts.caption())
                }
                .foregroundColor(Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            .disabled(content.isEmpty)
            
            // 发布到广场
            Button(action: {
                if authService.isAuthenticated {
                    publishToSquare()
                } else {
                    showLoginSheet = true
                }
            }) {
                HStack(spacing: 6) {
                    if isPublishing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("发布")
                        .fontWeight(.medium)
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
            }
            .disabled(content.isEmpty || isPublishing)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
    
    // MARK: - Actions
    
    private func handleStart() {
        // 检查是否有会员权限
        guard subscriptionManager.isSubscribed else {
            showingSubscription = true
            return
        }
        
        // 会员用户，开始生成主题
        generateTheme()
    }
    
    private func generateTheme() {
        isLoadingTheme = true
        
        Task {
            do {
                let result = try await AIService.shared.generatePoemThemeWithGuidance()
                await MainActor.run {
                    aiTheme = result.theme
                    aiGuidance = result.guidance
                    isLoadingTheme = false
                }
            } catch {
                await MainActor.run {
                    isLoadingTheme = false
                    toastManager.showError("主题生成失败，请重试")
                }
            }
        }
    }
    
    // MARK: - Save Actions
    
    /// 保存为草稿
    private func saveDraft() {
        guard !content.isEmpty else {
            toastManager.showError("诗歌内容不能为空")
            return
        }
        
        if authService.isAuthenticated {
            Task {
                do {
                    guard let userId = authService.currentUser?.id else { return }
                    _ = try await poemService.saveDraft(
                        authorId: userId,
                        title: title.isEmpty ? "无标题" : title,
                        content: content,
                        style: "modern"
                    )
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    print("保存草稿失败: \(error)")
                }
            }
        } else {
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: [],
                writingMode: .theme
            )
            poemManager.savePoem(newPoem)
            dismiss()
        }
    }
    
    /// 保存到诗集
    private func saveToCollection() {
        guard !content.isEmpty else {
            toastManager.showError("诗歌内容不能为空")
            return
        }
        
        let poem = Poem(
            title: title.isEmpty ? "无标题" : title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .theme,
            inMyCollection: true,
            inSquare: false
        )
        currentPoem = poem
        poemManager.saveToCollection(poem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
        }
    }
    
    /// 发布到广场
    private func publishToSquare() {
        guard authService.isAuthenticated,
              let userId = authService.currentUser?.id else {
            showLoginSheet = true
            return
        }
        
        guard !content.isEmpty else {
            toastManager.showError("诗歌内容不能为空")
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                _ = try await poemService.publishPoem(
                    authorId: userId,
                    title: title.isEmpty ? "无标题" : title,
                    content: content,
                    style: "modern"
                )
                
                await MainActor.run {
                    isPublishing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    print("发布失败: \(error)")
                }
            }
        }
    }
    
    private func showSaveAlert() {
        // TODO: 实现保存草稿确认弹窗
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ThemeWritingView()
    }
}

