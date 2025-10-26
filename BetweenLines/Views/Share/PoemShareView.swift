//
//  PoemShareView.swift
//  山海诗馆
//
//  诗歌分享页面：图片预览 + 分享操作
//

import SwiftUI

struct PoemShareView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var poemManager = PoemManager.shared
    
    let poem: Poem
    
    @State private var renderedImage: UIImage?
    @State private var showingTemplateSelector = false
    @State private var currentTemplate: PoemTemplate = .lovartMinimal
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 图片预览区域
                    ScrollView {
                        poemImagePreview
                            .padding(.vertical, Spacing.xl)
                    }
                    
                    // 底部操作按钮
                    bottomActions
                        .background(Colors.backgroundCream)
                }
            }
            .navigationTitle("分享")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Poem Image Preview
    
    private var poemImagePreview: some View {
        // 诗歌图片模板
        VStack(alignment: .leading, spacing: 32) {
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundColor(Color(hex: "0A0A0A"))
                    .tracking(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 正文
            Text(poem.content)
                .font(.system(size: 18, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "4A4A4A"))
                .lineSpacing(16)
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
                .frame(height: 40)
            
            // 底部标识
            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(hex: "E5E5E5"))
                
                // 山海诗馆 · 作者名 · 日期
                HStack(spacing: 4) {
                    Text("山海诗馆")
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "ABABAB"))
                        .tracking(2)
                    
                    Text("·")
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                    
                    Text(poem.authorName)
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                    
                    Text("·")
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                    
                    Text(poem.createdAt, style: .date)
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                }
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 64)
        .frame(width: 360)
        .background(Color.white)
        .cornerRadius(CornerRadius.large)
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        VStack(spacing: Spacing.md) {
            // 第一行：更换模板 + 保存图片
            HStack(spacing: Spacing.sm) {
                // 更换模板
                Button(action: {
                    showingTemplateSelector = true
                }) {
                    HStack {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 14))
                        Text("更换模板")
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
                
                // 保存图片
                Button(action: saveToPhotos) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 14))
                        Text("保存图片")
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Colors.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.accentTeal)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
            }
            
            // 第二行：微信 + 朋友圈 + 更多
            HStack(spacing: Spacing.sm) {
                // 微信
                Button(action: shareToWechat) {
                    VStack(spacing: 6) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "09BB07"))
                        Text("微信")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
                
                // 朋友圈
                Button(action: shareToMoments) {
                    VStack(spacing: 6) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "09BB07"))
                        Text("朋友圈")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
                
                // 更多
                Button(action: shareMore) {
                    VStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(Colors.accentTeal)
                        Text("更多")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
            }
        }
        .padding(Spacing.lg)
    }
    
    // MARK: - Actions
    
    /// 保存到相册
    private func saveToPhotos() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            await MainActor.run {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                toastManager.showSuccess("已保存到相册")
            }
        }
    }
    
    /// 分享到微信
    private func shareToWechat() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            await MainActor.run {
                // 🚧 TODO: 集成微信SDK后实现
                // 目前先使用系统分享
                presentSystemShare(with: image)
            }
        }
    }
    
    /// 分享到朋友圈
    private func shareToMoments() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            await MainActor.run {
                // 🚧 TODO: 集成微信SDK后实现
                // 目前先使用系统分享
                presentSystemShare(with: image)
            }
        }
    }
    
    /// 更多分享方式（系统分享面板）
    private func shareMore() {
        Task {
            guard let image = await renderPoemAsImage() else {
                await MainActor.run {
                    toastManager.showError("图片生成失败，请重试")
                }
                return
            }
            
            await MainActor.run {
                presentSystemShare(with: image)
            }
        }
    }
    
    /// 渲染诗歌为图片
    @MainActor
    private func renderPoemAsImage() async -> UIImage? {
        let renderer = ImageRenderer(content: poemImagePreview)
        renderer.scale = 3.0 // 3x 分辨率
        return renderer.uiImage
    }
    
    /// 调用系统分享面板
    @MainActor
    private func presentSystemShare(with image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            var topVC = rootVC
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            
            // iPad 需要设置 popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(
                    x: topVC.view.bounds.midX,
                    y: topVC.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
            
            topVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Poem Template

enum PoemTemplate: String, CaseIterable {
    case lovartMinimal = "Lovart 极简"
    // 🚧 TODO: 后续添加更多模板
}

// MARK: - Preview

#Preview {
    PoemShareView(
        poem: Poem(
            title: "夜思",
            content: "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡",
            authorName: "诗人",
            tags: [],
            writingMode: .direct
        )
    )
}

