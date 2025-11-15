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
    private let identityService = UserIdentityService()
    
    // AI 生成的主题和引导
    @State private var aiTheme: String = ""
    @State private var aiGuidance: String = "" // 创作引导
    @State private var isLoadingTheme = false
    
    // 创作内容
    @State private var title = ""
    @State private var content = ""
    @State private var currentPoem: Poem?
    @State private var showingSubscription = false
    // 移除 showSuccessView，保存后直接返回诗集
    @State private var generatedImage: UIImage?
    @State private var showingCancelConfirm = false
    @State private var hasSaved = false  // 跟踪是否已保存
    @State private var autoSaveTimer: Timer?  // 自动保存定时器
    // 草稿 ID（整个写作过程使用同一个 ID）
    @State private var draftId: String = UUID().uuidString
    
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
                    Button("保存") {
                        saveToCollection()
                    }
                    .disabled(content.isEmpty)
                    .foregroundColor(content.isEmpty ? Colors.textSecondary : Colors.accentTeal)
                }
            }
        }
        // 移除 PoemSuccessView，保存后直接返回诗集
        .alert("确认取消", isPresented: $showingCancelConfirm) {
            Button("放弃", role: .destructive) {
                dismiss()
            }
            Button("自动保存") {
                // 使用 autoSaveDraft() 方法保存诗歌（会更新现有诗歌或创建新诗歌）
                autoSaveDraft()
                ToastManager.shared.showSuccess("已自动保存")
                dismiss()
            }
            Button("继续编辑", role: .cancel) {}
        } message: {
            Text("诗歌尚未保存，是否自动保存？")
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .onAppear {
            if !aiTheme.isEmpty {
                startAutoSave()
            }
        }
        .onDisappear {
            stopAutoSave()
            // 退出前保存一次
            if !content.isEmpty && !hasSaved {
                autoSaveDraft()
            }
        }
        .onChange(of: content) { oldValue, newValue in
            // 内容变化时重置定时器
            if !newValue.isEmpty && !aiTheme.isEmpty {
                resetAutoSaveTimer()
            }
        }
        .onChange(of: aiTheme) { oldValue, newValue in
            // 主题生成后启动自动保存
            if !newValue.isEmpty {
                startAutoSave()
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
            
            // 编辑器（全屏，不显示字数统计）
            PoemEditorView(
                title: $title,
                content: $content,
                placeholder: "围绕主题「\(aiTheme)」，写下你的诗...",
                showWordCount: false
            )
        }
    }
    
    // MARK: - Theme Card
    
    private var themeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 头部：主题标题 + 换主题按钮
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("创作主题")
                        .font(Fonts.captionSmall())
                        .foregroundColor(Colors.textSecondary)
                    
                    Text(aiTheme)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                }
                
                Spacer()
                
                // 换主题按钮
                Button(action: {
                    generateTheme()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12))
                        Text("换一个")
                            .font(Fonts.captionSmall())
                    }
                    .foregroundColor(Colors.accentTeal)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(Colors.accentTeal.opacity(0.1))
                    .cornerRadius(CornerRadius.small)
                }
                .disabled(isLoadingTheme)
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
        // 检查是否可以使用主题写诗（非会员每天1次，会员无限）
        guard subscriptionManager.canUseThemeWriting() else {
            // 次数用完，弹出会员页面
            showingSubscription = true
            return
        }
        
        // 可以使用，开始生成主题
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
                    
                    // 生成成功，消耗一次额度
                    subscriptionManager.useThemeWriting()
                }
            } catch {
                await MainActor.run {
                    isLoadingTheme = false
                    toastManager.showError("主题生成失败，请重试")
                }
            }
        }
    }
    
    // MARK: - Auto Save
    
    /// 启动自动保存
    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            autoSaveDraft()
        }
    }
    
    /// 停止自动保存
    private func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    /// 重置自动保存定时器
    private func resetAutoSaveTimer() {
        stopAutoSave()
        startAutoSave()
    }
    
    /// 自动保存诗歌（统一为已完成状态）
    private func autoSaveDraft() {
        // 只有在有内容且未手动保存时才自动保存
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !hasSaved else { return }
        
        // 检查诗歌是否已存在
        if let existingPoem = poemManager.getPoem(by: draftId) {
            // ✅ 更新现有诗歌
            var updatedPoem = existingPoem
            updatedPoem.title = title.isEmpty ? "无标题" : title
            updatedPoem.content = content
            updatedPoem.inMyCollection = true  // 统一为已完成状态
            updatedPoem.updatedAt = Date()
            poemManager.savePoem(updatedPoem)
            print("📝 [ThemeWriting] 自动保存 - 已更新诗歌: \(draftId)")
        } else {
            // ✅ 首次创建诗歌（使用固定的 draftId）
            let poem = Poem(
                id: draftId,  // 使用固定ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,  // 设置 userId
                tags: [],
                writingMode: .theme,
                inMyCollection: true,  // 统一为已完成状态
                inSquare: false
            )
            poemManager.savePoem(poem)  // savePoem 现在会自动添加新诗歌
            print("📝 [ThemeWriting] 自动保存 - 已创建诗歌: \(draftId)")
        }
    }
    
    // MARK: - Save Actions
    
    /// 保存诗歌（统一保存，不再区分草稿和诗集）
    private func saveToCollection() {
        // 检查是否有对应的诗歌
        if let existingPoem = poemManager.getPoem(by: draftId) {
            // ✅ 更新现有诗歌
            var poemToSave = existingPoem
            poemToSave.title = title.isEmpty ? "无标题" : title
            poemToSave.content = content
            poemToSave.inMyCollection = true  // 统一为已完成状态
            poemToSave.updatedAt = Date()
            
            let saved = poemManager.saveToCollection(poemToSave)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经保存过了")
                return
            }
            print("📚 [ThemeWriting] 已更新诗歌: \(draftId)")
        } else {
            // ✅ 创建新诗歌
            let newPoem = Poem(
                id: draftId,  // 使用同一个ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,
                tags: [],
                writingMode: .theme,
                inMyCollection: true,  // 统一为已完成状态
                inSquare: false
            )
            
            let saved = poemManager.saveToCollection(newPoem)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经保存过了")
                return
            }
            print("📚 [ThemeWriting] 已创建新诗歌: \(draftId)")
        }
        
        hasSaved = true  // 标记已保存
        
        // Toast 提示
        ToastManager.shared.showSuccess("已保存")
        
        // 1秒后返回诗集
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ThemeWritingView()
    }
}

