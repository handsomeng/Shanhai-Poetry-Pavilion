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
    
    // AI 生成的示例诗
    @State private var aiExamplePoem: String = ""
    @State private var isLoadingExample = false
    
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
            
            // 首次进入，自动生成示例
            if aiExamplePoem.isEmpty {
                generateExample()
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
                
                Text("让 AI 为你生成一首示例诗")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                    .multilineTextAlignment(.center)
                
                Text("对照学习，提升创作技巧")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: generateExample) {
                Text("生成示例")
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
            // 上半部分：AI 示例诗
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("示例诗歌")
                        .font(Fonts.h2Small())
                        .foregroundColor(Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("AI 生成")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.accentTeal)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Colors.accentTeal.opacity(0.1))
                        .cornerRadius(CornerRadius.small)
                }
                
                ScrollView {
                    Text(aiExamplePoem)
                        .font(Fonts.bodyPoem())
                        .foregroundColor(Colors.textInk)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(Spacing.lg)
            .frame(height: UIScreen.main.bounds.height * 0.35)
            .background(Colors.white.opacity(0.5))
            
            Divider()
                .background(Colors.border)
            
            // 下半部分：用户创作区
            VStack(spacing: 0) {
                // 标题
                Text("你的创作")
                    .font(Fonts.h2Small())
                    .foregroundColor(Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.sm)
                
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
    
    private func generateExample() {
        // 检查是否有权限
        guard subscriptionManager.isSubscribed else {
            toastManager.showError("模仿写诗需要会员权限")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingSubscription = true
            }
            return
        }
        
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
            writingMode: .mimic,
            referencePoem: "AI 示例",
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
        MimicWritingView()
    }
}
