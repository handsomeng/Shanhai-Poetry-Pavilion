//
//  PoemSuccessView.swift
//  山海诗馆
//
//  诗歌保存成功页面
//

import SwiftUI
import Photos

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
                
                // 可滚动内容区域
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: Spacing.xl) {
                        // 诗歌图片（完整显示）
                        Image(uiImage: poemImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(CornerRadius.large)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.md)
                        
                        // 操作按钮
                        actionButtons
                            .padding(.bottom, Spacing.xl)
                    }
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
        guard !poem.content.isEmpty else { return }
        
        // 立即显示sheet（带loading状态）
        isLoadingAI = true
        aiComment = ""
        showAIComment = true
        
        // 调用DeepSeek API进行真实的AI点评
        Task {
            do {
                let comment = try await AIService.shared.getPoemComment(content: poem.content)
                await MainActor.run {
                    aiComment = comment
                    isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    aiComment = "AI 点评暂时无法生成，请稍后重试。\n\n错误信息：\(error.localizedDescription)"
                    isLoadingAI = false
                }
            }
        }
    }
    
    /// 保存图片到相册
    private func saveImageToAlbum() {
        print("🖼️ [PoemSuccessView] 开始保存图片到相册...")
        
        // 使用iOS 14+的新API，支持.add权限
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                print("📸 [PoemSuccessView] 相册权限状态: \(status.rawValue)")
                
                switch status {
                case .authorized, .limited:
                    print("✅ [PoemSuccessView] 权限已授权，正在保存图片...")
                    UIImageWriteToSavedPhotosAlbum(self.poemImage, nil, nil, nil)
                    ToastManager.shared.showSuccess("图片已保存到相册")
                    print("✅ [PoemSuccessView] Toast已显示")
                    
                case .denied, .restricted:
                    print("❌ [PoemSuccessView] 权限被拒绝")
                    ToastManager.shared.showError("请在设置中允许访问相册")
                    
                case .notDetermined:
                    print("⚠️ [PoemSuccessView] 权限未确定")
                    ToastManager.shared.showError("请授予相册访问权限")
                    
                @unknown default:
                    print("⚠️ [PoemSuccessView] 未知权限状态")
                    break
                }
            }
        }
    }
    
    /// 分享
    private func sharePoem() {
        print("📤 [PoemSuccessView] 开始分享图片...")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("❌ [PoemSuccessView] 无法获取windowScene")
            ToastManager.shared.showError("无法打开分享")
            return
        }
        
        guard let window = windowScene.windows.first else {
            print("❌ [PoemSuccessView] 无法获取window")
            ToastManager.shared.showError("无法打开分享")
            return
        }
        
        guard let rootVC = window.rootViewController else {
            print("❌ [PoemSuccessView] 无法获取rootViewController")
            ToastManager.shared.showError("无法打开分享")
            return
        }
        
        // 找到最顶层的ViewController
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        print("✅ [PoemSuccessView] 找到topViewController: \(type(of: topVC))")
        
        // 创建分享面板
        let activityVC = UIActivityViewController(
            activityItems: [poemImage],
            applicationActivities: nil
        )
        
        // 完成回调（调试用）
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                print("❌ [PoemSuccessView] 分享失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    ToastManager.shared.showError("分享失败：\(error.localizedDescription)")
                }
            } else if completed {
                print("✅ [PoemSuccessView] 分享成功: \(activityType?.rawValue ?? "unknown")")
                DispatchQueue.main.async {
                    ToastManager.shared.showSuccess("分享成功")
                }
            } else {
                print("⚠️ [PoemSuccessView] 用户取消分享")
            }
        }
        
        // iPad支持
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = topVC.view
            popoverController.sourceRect = CGRect(
                x: topVC.view.bounds.midX, 
                y: topVC.view.bounds.midY, 
                width: 0, 
                height: 0
            )
            popoverController.permittedArrowDirections = []
            print("✅ [PoemSuccessView] 已配置iPad popover")
        }
        
        print("🚀 [PoemSuccessView] 正在显示分享面板...")
        topVC.present(activityVC, animated: true) {
            print("✅ [PoemSuccessView] 分享面板已显示")
        }
    }
    
    /// 发布到广场
    private func publishToSquare() {
        // 检查是否登录
        guard authService.isAuthenticated else {
            showLoginSheet = true
            return
        }
        
        // 检查userId
        guard let userId = authService.currentUser?.id else {
            ToastManager.shared.showError("用户信息异常，请重新登录")
            return
        }
        
        // 检查内容
        guard !poem.content.isEmpty else {
            ToastManager.shared.showError("诗歌内容不能为空")
            return
        }
        
        isPublishing = true
        ToastManager.shared.showInfo("正在提交审核...")
        
        Task {
            do {
                print("🚀 [PoemSuccessView] 开始发布到广场...")
                print("📝 [PoemSuccessView] 作者ID: \(userId)")
                print("📝 [PoemSuccessView] 标题: \(poem.title.isEmpty ? "无标题" : poem.title)")
                print("📝 [PoemSuccessView] 内容长度: \(poem.content.count)")
                
                // 发布到云端
                let publishedPoem = try await poemService.publishPoem(
                    authorId: userId,
                    title: poem.title.isEmpty ? "无标题" : poem.title,
                    content: poem.content,
                    style: "modern"
                )
                
                print("✅ [PoemSuccessView] 发布成功！诗歌ID: \(publishedPoem.id)")
                
                await MainActor.run {
                    isPublishing = false
                    
                    // 更新本地状态为审核中
                    var updatedPoem = poem
                    updatedPoem.auditStatus = .pending
                    updatedPoem.inSquare = false
                    PoemManager.shared.savePoem(updatedPoem)
                    
                    // 提示用户
                    ToastManager.shared.showSuccess("已提交审核，请耐心等待")
                    
                    // 延迟关闭，让用户看到提示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                print("❌ [PoemSuccessView] 发布失败：\(error)")
                
                await MainActor.run {
                    isPublishing = false
                    
                    // 更详细的错误信息
                    let errorMessage: String
                    if error.localizedDescription.contains("Network") || error.localizedDescription.contains("network") {
                        errorMessage = "网络连接失败，请检查网络后重试"
                    } else if error.localizedDescription.contains("401") || error.localizedDescription.contains("403") {
                        errorMessage = "登录已过期，请重新登录"
                    } else {
                        errorMessage = "发布失败：\(error.localizedDescription)"
                    }
                    
                    ToastManager.shared.showError(errorMessage)
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


