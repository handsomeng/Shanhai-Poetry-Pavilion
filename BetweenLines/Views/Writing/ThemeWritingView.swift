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
            
            // 首次进入，自动生成主题
            if aiTheme.isEmpty {
                generateTheme()
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
                
                Text("让 AI 为你推荐一个主题")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                    .multilineTextAlignment(.center)
                
                Text("围绕主题展开你的创作")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: generateTheme) {
                Text("生成主题")
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
            Button(action: savePoem) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("保存")
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
            }
            .scaleButtonStyle()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
    }
    
    // MARK: - Actions
    
    private func generateTheme() {
        // 检查是否有权限
        guard subscriptionManager.isSubscribed else {
            toastManager.showError("主题写诗需要会员权限")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingSubscription = true
            }
            return
        }
        
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
    
    private func savePoem() {
        guard !content.isEmpty else {
            toastManager.showError("诗歌内容不能为空")
            return
        }
        
        // 创建新诗歌并保存到诗集
        let poem = Poem(
            title: title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .theme,
            inMyCollection: true,
            inSquare: false
        )
        currentPoem = poem
        poemManager.saveToCollection(poem)
        
        // 保存成功后，显示分享选项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
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
