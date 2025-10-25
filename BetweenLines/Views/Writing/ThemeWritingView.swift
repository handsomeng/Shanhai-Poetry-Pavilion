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
    @StateObject private var poemService = PoemService.shared
    
    // AI 生成的主题和引导
    @State private var aiTheme: String = ""
    @State private var aiGuidance: String = "" // 创作引导
    @State private var isLoadingTheme = false
    
    // 创作内容
    @State private var title = ""
    @State private var content = ""
    @State private var currentPoem: Poem?
    @State private var isKeyboardVisible = false
    @State private var showingSubscription = false
    @State private var showSuccessView = false
    @State private var generatedImage: UIImage?
    @State private var showingCancelConfirm = false
    @State private var hasSaved = false  // 跟踪是否已保存
    
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
                    // 如果已保存，直接关闭
                    if hasSaved {
                        dismiss()
                    } else if content.isEmpty && title.isEmpty {
                        dismiss()
                    } else {
                        showingCancelConfirm = true
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
        .fullScreenCover(isPresented: $showSuccessView) {
            if let poem = currentPoem, let image = generatedImage {
                PoemSuccessView(poem: poem, poemImage: image)
            }
        }
        .alert("确认取消", isPresented: $showingCancelConfirm) {
            Button("放弃", role: .destructive) {
                dismiss()
            }
            Button("自动保存草稿") {
                let draft = poemManager.createDraft(
                    title: title,
                    content: content,
                    tags: [],
                    writingMode: .theme
                )
                poemManager.savePoem(draft)
                ToastManager.shared.showSuccess("已自动保存到草稿")
                dismiss()
            }
            Button("继续编辑", role: .cancel) {}
        } message: {
            Text("诗歌尚未保存，是否保存为草稿？")
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
        Button(action: saveToCollection) {
            Text("保存到诗集")
                .font(Fonts.bodyLarge())
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
        }
        .disabled(content.isEmpty)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
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
    
    /// 保存到诗集
    private func saveToCollection() {
        let newPoem = Poem(
            title: title.isEmpty ? "无标题" : title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .theme,
            inMyCollection: true,
            inSquare: false
        )
        
        // 检查重复并保存
        let saved = poemManager.saveToCollection(newPoem)
        
        if !saved {
            // 重复诗歌，显示提示
            ToastManager.shared.showInfo("这首诗已经在诗集中了")
            return
        }
        
        currentPoem = newPoem
        hasSaved = true  // 标记已保存
        
        // 生成分享图片
        generatedImage = PoemImageGenerator.generate(poem: newPoem)
        
        // Toast 提示
        ToastManager.shared.showSuccess("已保存到你的诗集")
        
        // 显示成功页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showSuccessView = true
        }
    }
}

#Preview {
    NavigationStack {
        ThemeWritingView()
    }
}

