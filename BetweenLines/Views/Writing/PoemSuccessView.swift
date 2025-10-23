//
//  PoemSuccessView.swift
//  山海诗馆
//
//  诗歌保存成功页面
//

import SwiftUI

struct PoemSuccessView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    
    let poem: Poem
    let poemImage: UIImage
    
    @State private var isPublishing = false
    @State private var showLoginSheet = false
    @State private var showAIComment = false
    @State private var aiComment = ""
    @State private var isLoadingAI = false
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部关闭按钮
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Colors.textSecondary.opacity(0.6))
                    }
                    .padding(.trailing, Spacing.lg)
                    .padding(.top, Spacing.md)
                }
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 诗歌图片
                        Image(uiImage: poemImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(CornerRadius.large)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.top, Spacing.lg)
                        
                        // 操作按钮
                        actionButtons
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
        .sheet(isPresented: $showAIComment) {
            AICommentSheet(comment: aiComment, isLoading: isLoadingAI)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: Spacing.md) {
            // 第一行：3个次要按钮
            HStack(spacing: Spacing.sm) {
                // AI 点评
                Button(action: requestAIComment) {
                    VStack(spacing: 4) {
                        if isLoadingAI {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(Colors.accentTeal)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                        }
                        Text(isLoadingAI ? "点评中..." : "AI点评")
                            .font(Fonts.caption())
                    }
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .disabled(isLoadingAI)
                
                // 保存图片
                Button(action: saveImageToAlbum) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 20))
                        Text("保存图片")
                            .font(Fonts.caption())
                    }
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                
                // 分享
                Button(action: sharePoem) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                        Text("分享")
                            .font(Fonts.caption())
                    }
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
            }
            
            // 第二行：发布到广场按钮
            Button(action: publishToSquare) {
                HStack(spacing: 8) {
                    if isPublishing {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(authService.isAuthenticated ? "发布到广场" : "登录后发布到广场")
                        .fontWeight(.medium)
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
            }
            .disabled(isPublishing)
        }
        .padding(.horizontal, Spacing.xl)
    }
    
    // MARK: - Actions
    
    /// AI 点评
    private func requestAIComment() {
        // TODO: 实现AI点评功能
        isLoadingAI = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoadingAI = false
            aiComment = "这是一首很有意境的诗歌..."
            showAIComment = true
        }
    }
    
    /// 保存图片到相册
    private func saveImageToAlbum() {
        UIImageWriteToSavedPhotosAlbum(poemImage, nil, nil, nil)
        ToastManager.shared.showSuccess("图片已保存到相册")
    }
    
    /// 分享
    private func sharePoem() {
        let activityVC = UIActivityViewController(
            activityItems: [poemImage],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    /// 发布到广场
    private func publishToSquare() {
        guard authService.isAuthenticated else {
            showLoginSheet = true
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                guard let userId = authService.currentUser?.id else { return }
                
                // 发布到云端
                _ = try await poemService.publishPoem(
                    authorId: userId,
                    title: poem.title.isEmpty ? "无标题" : poem.title,
                    content: poem.content,
                    style: "modern"
                )
                
                await MainActor.run {
                    isPublishing = false
                    
                    // 更新本地状态为审核中
                    var updatedPoem = poem
                    updatedPoem.auditStatus = .pending
                    updatedPoem.inSquare = false
                    PoemManager.shared.savePoem(updatedPoem)
                    
                    // 提示用户
                    ToastManager.shared.showSuccess("已提交审核，请耐心等待")
                    
                    // 关闭成功页面
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    ToastManager.shared.showError("发布失败：\(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PoemSuccessView(
        poem: Poem.example,
        poemImage: UIImage(systemName: "photo")!
    )
}


