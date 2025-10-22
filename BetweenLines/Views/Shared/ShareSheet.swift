//
//  ShareSheet.swift
//  山海诗馆
//
//  分享面板：分享到广场或生成图片
//

import SwiftUI

struct ShareSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    let poem: Poem
    
    @State private var showingImageShare = false
    @State private var showingAIComment = false
    @State private var aiComment = ""
    @State private var isLoadingAI = false
    @State private var isPublishing = false
    @State private var showingSubscription = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 诗歌预览
                    ScrollView {
                        poemPreview
                            .padding(.top, Spacing.md)
                            .padding(.bottom, 120) // 为底部按钮留空间
                    }
                    
                    // 底部置底按钮
                    bottomActions
                }
            }
            .navigationTitle("保存成功")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                }
            }
                  .sheet(isPresented: $showingImageShare) {
                      PoemImageView(poem: poem)
                  }
                  .sheet(isPresented: $showingAIComment) {
                      AICommentSheet(comment: aiComment, isLoading: isLoadingAI)
                  }
                  .sheet(isPresented: $showingSubscription) {
                      SubscriptionView()
                  }
        }
    }
    
    // MARK: - Poem Preview
    
    private var poemPreview: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(Fonts.h2Small())
                    .foregroundColor(Colors.textInk)
            }
            
            Text(poem.content)
                .font(Fonts.bodyPoem())
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .padding(.horizontal, Spacing.lg)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        VStack(spacing: Spacing.xs) {
            // 分享到广场（只有未发布的才显示）
            if poem.squareId == nil {
                Button(action: publishToSquare) {
                    HStack {
                        if isPublishing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isPublishing ? "发布中..." : "分享到广场")
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.accentTeal)
                    .cornerRadius(CornerRadius.medium)
                }
                .disabled(isPublishing)
                .scaleButtonStyle()
            }
            
            HStack(spacing: Spacing.xs) {
                // 生成图片
                Button(action: { showingImageShare = true }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                        Text("生成图片")
                    }
                    .font(Fonts.bodySmall())
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.sm)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
                
                // AI 点评
                Button(action: requestAIComment) {
                    HStack {
                        if isLoadingAI {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                        }
                        Text(isLoadingAI ? "点评中..." : "AI 点评")
                    }
                    .font(Fonts.bodySmall())
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.sm)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .disabled(isLoadingAI)
                .scaleButtonStyle()
            }
        }
        .padding(Spacing.md)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Actions
    
    private func publishToSquare() {
        isPublishing = true
        
        // Step 1: AI 内容审核
        Task {
            do {
                let moderationResult = try await AIService.shared.moderateContent(
                    title: poem.title,
                    content: poem.content
                )
                
                await MainActor.run {
                    if !moderationResult.pass {
                        // 审核不通过
                        isPublishing = false
                        let reason = moderationResult.reason ?? "内容不符合社区规范"
                        toastManager.showError("无法发布：\(reason)")
                        return
                    }
                    
                    // Step 2: 审核通过，执行发布
                    do {
                        try poemManager.publishToSquare(poem)
                        toastManager.showSuccess("诗歌已发布到广场")
                        
                        // 延迟关闭，让用户看到成功提示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isPublishing = false
                            dismiss()
                        }
                    } catch {
                        isPublishing = false
                        if let publishError = error as? PoemPublishError {
                            toastManager.showError(publishError.errorDescription ?? "发布失败")
                        } else {
                            toastManager.showError("发布失败，请重试")
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    toastManager.showError("内容审核失败，请重试")
                }
            }
        }
    }
    
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
                    aiComment = "AI 点评暂时无法生成，请稍后重试"
                    isLoadingAI = false
                    showingAIComment = true
                }
            }
        }
    }
}

// MARK: - AI Comment Sheet

struct AICommentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let comment: String
    let isLoading: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(Colors.accentTeal)
                        Text("AI 诗评")
                            .font(Fonts.titleMedium())
                            .foregroundColor(Colors.textInk)
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("AI 正在点评...")
                                .font(Fonts.body())
                                .foregroundColor(Colors.textSecondary)
                        }
                        .padding(.vertical, Spacing.xl)
                    } else {
                        Text(comment)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textSecondary)
                            .lineSpacing(6)
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Colors.backgroundCream)
            .navigationTitle("AI 点评")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
}

