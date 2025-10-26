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
    @State private var selectedTemplate: PoemTemplateType = .lovartMinimal
    
    // 计算这是第几首诗
    private var poemIndex: Int {
        // 获取用户所有诗歌（包括诗集和草稿）的总数
        poemManager.allPoems.count
    }
    
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
            .fullScreenCover(isPresented: $showingTemplateSelector) {
                TemplateSelector(selectedTemplate: $selectedTemplate, poem: poem)
            }
        }
    }
    
    // MARK: - Poem Image Preview
    
    private var poemImagePreview: some View {
        // 使用当前选择的模板渲染
        selectedTemplate.render(
            poem: poem,
            poemIndex: poemIndex,
            size: CGSize(width: 340, height: 0)
        )
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        // 仿照 Flomo 的底部按钮布局
        HStack(spacing: 0) {
            // 更换模板
            ActionButton(
                icon: "circle.grid.2x2",
                title: "更换模板",
                action: {
                    showingTemplateSelector = true
                }
            )
            
            Divider()
                .frame(height: 40)
                .background(Color(hex: "E5E5E5"))
            
            // 保存图片
            ActionButton(
                icon: "arrow.down.circle",
                title: "保存图片",
                action: saveToPhotos
            )
            
            Divider()
                .frame(height: 40)
                .background(Color(hex: "E5E5E5"))
            
            // 微信
            ActionButton(
                icon: "message",
                title: "微信",
                iconColor: Color(hex: "09BB07"),
                action: shareToWechat
            )
            
            Divider()
                .frame(height: 40)
                .background(Color(hex: "E5E5E5"))
            
            // 朋友圈
            ActionButton(
                icon: "person.3",
                title: "朋友圈",
                iconColor: Color(hex: "09BB07"),
                action: shareToMoments
            )
            
            Divider()
                .frame(height: 40)
                .background(Color(hex: "E5E5E5"))
            
            // 更多
            ActionButton(
                icon: "ellipsis.circle",
                title: "更多",
                action: shareMore
            )
        }
        .frame(height: 70)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(hex: "E5E5E5")),
            alignment: .top
        )
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let title: String
    var iconColor: Color = Color(hex: "666666")
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "666666"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isPressed ? Color(hex: "F5F5F5") : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Poem Share View Extension

extension PoemShareView {
    
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

