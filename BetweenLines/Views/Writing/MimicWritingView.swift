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
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    
    // AI 生成的示例诗
    @State private var aiExamplePoem: String = ""
    @State private var isLoadingExample = false
    @State private var isExampleExpanded = false // 示例诗是否展开
    
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
                    if content.isEmpty && title.isEmpty {
                        dismiss()
                    } else {
                        // 有内容时，显示保存草稿确认
                        showSaveAlert()
                    }
                }
            }
            
            if !aiExamplePoem.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("换一首") {
                        generateExample()
                    }
                    .disabled(isLoadingExample)
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
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExampleExpanded.toggle()
                }
            }) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("示例诗歌")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("AI 生成")
                                .font(Fonts.captionSmall())
                                .foregroundColor(Colors.accentTeal)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Colors.accentTeal.opacity(0.1))
                                .cornerRadius(CornerRadius.small)
                            
                            Image(systemName: isExampleExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                    
                    Text(aiExamplePoem)
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textInk)
                        .lineSpacing(6)
                        .lineLimit(isExampleExpanded ? nil : 3) // 展开时无限制，否则3行
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.md)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Colors.backgroundCream.opacity(0.5))
            
            Divider()
                .background(Colors.border.opacity(0.3))
            
            // 下半部分：用户创作区
            VStack(spacing: 0) {
                // 编辑器
                PoemEditorView(
                    title: $title,
                    content: $content,
                    placeholder: "对照示例，写下你的诗...",
                    showWordCount: !isKeyboardVisible
                )
            }
            .background(Colors.white)
            
            // 底部按钮
            if !isKeyboardVisible {
                bottomButtons
            }
        }
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
        
        // 会员用户，开始生成示例
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
                }
            } catch {
                await MainActor.run {
                    isLoadingExample = false
                    toastManager.showError("示例生成失败，请重试")
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
                writingMode: .mimic
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
            writingMode: .mimic,
            referencePoem: "AI 示例",
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
        MimicWritingView()
    }
}

