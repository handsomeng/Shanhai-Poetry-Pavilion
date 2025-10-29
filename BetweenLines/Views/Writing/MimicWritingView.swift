//
//  MimicWritingView.swift
//  山海诗馆
//
//  模仿写诗模式：AI 生成示例诗歌，用户对照创作
//

import SwiftUI

struct MimicWritingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var poemService = PoemService.shared
    private let identityService = UserIdentityService()
    
    // AI 生成的示例诗
    @State private var aiExamplePoem: String = ""
    @State private var isLoadingExample = false
    @State private var isExampleExpanded = false // 示例诗是否展开
    
    // 创作内容
    @State private var title = ""
    @State private var content = ""
    @State private var showingSubscription = false
    @State private var showingCancelConfirm = false
    @State private var hasSaved = false  // 跟踪是否已保存
    @State private var autoSaveTimer: Timer?  // 自动保存定时器
    // 草稿 ID（整个写作过程使用同一个 ID）
    @State private var draftId: String = UUID().uuidString
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            if isLoadingExample {
                loadingView
            } else if aiExamplePoem.isEmpty {
                generatePromptView
            } else {
                splitView
            }
        }
        .navigationTitle("模仿写诗")
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
            
            if !aiExamplePoem.isEmpty {
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
            Button("自动保存草稿") {
                // 使用 autoSaveDraft() 方法保存草稿（会更新现有草稿或创建新草稿）
                autoSaveDraft()
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
            if !aiExamplePoem.isEmpty {
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
            if !newValue.isEmpty && !aiExamplePoem.isEmpty {
                resetAutoSaveTimer()
            }
        }
        .onChange(of: aiExamplePoem) { oldValue, newValue in
            // 示例生成后启动自动保存
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
            
            Text("AI 正在创作示例诗歌...")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Generate Prompt View
    
    private var generatePromptView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            VStack(spacing: Spacing.lg) {
                Text("🎨")
                    .font(.system(size: 64))
                
                Text("模仿写诗")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                    .multilineTextAlignment(.center)
                
                Text("AI 为你生成一首示例诗\n对照学习，提升创作技巧")
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
    
    // MARK: - Split View
    
    private var splitView: some View {
        VStack(spacing: 0) {
            // 上半部分：AI 示例诗（可展开）
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("示例诗歌")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExampleExpanded.toggle()
                            }
                        }) {
                            Text(aiExamplePoem)
                                .font(Fonts.bodyRegular())
                                .foregroundColor(Colors.textInk)
                                .lineSpacing(6)
                                .lineLimit(isExampleExpanded ? nil : 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 换一首按钮
                    Button(action: {
                        generateExample()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12))
                            Text("换一首")
                                .font(Fonts.captionSmall())
                        }
                        .foregroundColor(Colors.accentTeal)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 6)
                        .background(Colors.accentTeal.opacity(0.1))
                        .cornerRadius(CornerRadius.small)
                    }
                    .disabled(isLoadingExample)
                }
            }
            .padding(Spacing.md)
            .background(Colors.backgroundCream.opacity(0.5))
            
            Divider()
                .background(Colors.border.opacity(0.3))
            
            // 下半部分：用户创作区（全屏，不显示字数统计）
            PoemEditorView(
                title: $title,
                content: $content,
                placeholder: "对照示例，写下你的诗...",
                showWordCount: false
            )
            .background(Colors.white)
        }
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
        // 检查是否可以使用临摹写诗（非会员每天1次，会员无限）
        guard subscriptionManager.canUseMimicWriting() else {
            // 次数用完，弹出会员页面
            showingSubscription = true
            return
        }
        
        // 可以使用，开始生成示例
        generateExample()
    }
    
    private func generateExample() {
        isLoadingExample = true
        
        Task {
            do {
                let example = try await AIService.shared.generateExamplePoem()
                await MainActor.run {
                    aiExamplePoem = example
                    isLoadingExample = false
                    
                    // 生成成功，消耗一次额度
                    subscriptionManager.useMimicWriting()
                }
            } catch {
                await MainActor.run {
                    isLoadingExample = false
                    toastManager.showError("示例生成失败，请重试")
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
    
    /// 自动保存草稿
    private func autoSaveDraft() {
        // 只有在有内容且未手动保存时才自动保存
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !hasSaved else { return }
        
        // 检查草稿是否已存在
        if let existingDraft = poemManager.getPoem(by: draftId) {
            // ✅ 更新现有草稿
            var updatedDraft = existingDraft
            updatedDraft.title = title.isEmpty ? "无标题" : title
            updatedDraft.content = content
            updatedDraft.updatedAt = Date()
            poemManager.savePoem(updatedDraft)
            print("📝 [MimicWriting] 自动保存 - 已更新草稿: \(draftId)")
        } else {
            // ✅ 首次创建草稿（使用固定的 draftId）
            let draft = Poem(
                id: draftId,  // 使用固定ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,  // 设置 userId
                tags: [],
                writingMode: .mimic,
                referencePoem: "AI 示例",
                inMyCollection: false,  // 草稿状态
                inSquare: false
            )
            poemManager.savePoem(draft)  // savePoem 现在会自动添加新诗歌
            print("📝 [MimicWriting] 自动保存 - 已创建草稿: \(draftId)")
        }
    }
    
    // MARK: - Save Actions
    
    /// 保存为草稿
    private func saveDraft() {
        guard !content.isEmpty else {
            toastManager.showError("诗歌内容不能为空")
            return
        }
        
        // 保存到本地
        let newPoem = poemManager.createDraft(
            title: title,
            content: content,
            tags: [],
            writingMode: .mimic
        )
        poemManager.savePoem(newPoem)
        dismiss()
    }
    
    /// 保存到诗集
    private func saveToCollection() {
        // 1. 检查是否有对应的草稿
        if let existingDraft = poemManager.getPoem(by: draftId), !existingDraft.inMyCollection {
            // ✅ 将草稿转为诗集作品（保持同一个ID）
            var poemToSave = existingDraft
            poemToSave.title = title.isEmpty ? "无标题" : title
            poemToSave.content = content
            poemToSave.inMyCollection = true  // 转为诗集
            poemToSave.updatedAt = Date()
            
            let saved = poemManager.saveToCollection(poemToSave)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经在诗集中了")
                return
            }
            print("📚 [MimicWriting] 草稿已转为诗集: \(draftId)")
        } else {
            // ✅ 没有草稿，直接创建新诗歌（极少发生，除非自动保存失败）
            let newPoem = Poem(
                id: draftId,  // 使用同一个ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,
                tags: [],
                writingMode: .mimic,
                referencePoem: "AI 示例",
                inMyCollection: true,
                inSquare: false
            )
            
            let saved = poemManager.saveToCollection(newPoem)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经在诗集中了")
                return
            }
            print("📚 [MimicWriting] 直接创建诗集作品: \(draftId)")
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
        MimicWritingView()
    }
}

