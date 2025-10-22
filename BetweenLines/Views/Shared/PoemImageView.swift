//
//  PoemImageView.swift
//  山海诗馆
//
//  诗歌图片生成：Lovart 风格极简黑白模板
//

import SwiftUI

struct PoemImageView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    let poem: Poem
    
    @State private var renderedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 预览区域（可滚动）
                    ScrollView {
                        poemTemplate
                            .padding(.vertical, Spacing.xl)
                            .padding(.bottom, Spacing.lg) // 为底部按钮留空间
                    }
                    
                    // 操作按钮（固定在底部）
                    actionButtons
                        .background(Colors.backgroundCream)
                        .padding(.bottom, Spacing.md)
                }
            }
            .navigationTitle("生成图片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Poem Template
    
    private var poemTemplate: some View {
        // 这个 View 会被转换成图片（长图，动态高度）
        VStack(alignment: .leading, spacing: 32) {
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 32, weight: .thin, design: .serif))
                    .foregroundColor(Color(hex: "0A0A0A"))
                    .tracking(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 正文 - 修复行距
            Text(poem.content)
                .font(.system(size: 20, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "4A4A4A"))
                .lineSpacing(18) // 增加行距
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true) // 允许垂直扩展
            
            Spacer()
                .frame(height: 32)
            
            // 底部信息
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(hex: "E5E5E5"))
                
                HStack {
                    Text(poem.authorName)
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                    
                    Spacer()
                    
                    Text("山海诗馆")
                        .font(.system(size: 13, weight: .ultraLight, design: .serif))
                        .foregroundColor(Color(hex: "ABABAB"))
                        .tracking(2)
                }
            }
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 72)
        .frame(width: 400) // 固定宽度，高度自适应
        .background(Color.white)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: Spacing.sm) {
            // 保存到相册
            Button(action: saveToPhotos) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .light))
                    Text("保存到相册")
                        .font(Fonts.bodyRegular())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
            }
            .scaleButtonStyle()
            
            // 使用系统分享
            Button(action: shareImage) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .light))
                    Text("分享")
                        .font(Fonts.bodyRegular())
                }
                .foregroundColor(Colors.textInk)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.white)
                .cornerRadius(CornerRadius.medium)
            }
            .scaleButtonStyle()
        }
        .padding(.horizontal, Spacing.lg)
    }
    
    // MARK: - Actions
    
    private func saveToPhotos() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            // 在主线程保存到相册
            await MainActor.run {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                toastManager.showSuccess("图片已保存到相册")
                
                // 延迟关闭
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
    
    private func shareImage() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            // 在主线程使用系统分享
            await MainActor.run {
                let activityVC = UIActivityViewController(
                    activityItems: [image],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    
                    // 查找最顶层的 VC
                    var topVC = rootVC
                    while let presentedVC = topVC.presentedViewController {
                        topVC = presentedVC
                    }
                    
                    // iPad 需要设置 popover
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = topVC.view
                        popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    topVC.present(activityVC, animated: true)
                }
            }
        }
    }
    
    @MainActor
    private func renderPoemAsImage() async -> UIImage? {
        // 创建渲染器
        let renderer = ImageRenderer(content: poemTemplate)
        renderer.scale = 3.0 // 3x 分辨率，确保清晰
        
        // 异步渲染，避免卡住
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = renderer.uiImage
                continuation.resume(returning: image)
            }
        }
    }
}

