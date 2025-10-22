//
//  PoemImageView.swift
//  山海诗馆
//
//  诗歌图片生成：Lovart 风格极简黑白模板
//

import SwiftUI

struct PoemImageView: View {
    
    @Environment(\.dismiss) private var dismiss
    let poem: Poem
    
    @State private var renderedImage: UIImage?
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    // 预览区域
                    poemTemplate
                        .padding(.top, Spacing.xl)
                    
                    Spacer()
                    
                    // 操作按钮
                    actionButtons
                        .padding(.bottom, Spacing.xl)
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
            .alert("提示", isPresented: $showingSaveAlert) {
                Button("确定") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Poem Template
    
    private var poemTemplate: some View {
        // 这个 View 会被转换成图片
        ZStack {
            Color.white
            
            VStack(spacing: 0) {
                Spacer()
                
                // 诗歌内容
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // 标题（如果有）
                    if !poem.title.isEmpty {
                        Text(poem.title)
                            .font(.system(size: 28, weight: .thin, design: .serif))
                            .foregroundColor(Color(hex: "0A0A0A"))
                            .tracking(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 正文
                    Text(poem.content)
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "4A4A4A"))
                        .lineSpacing(12)
                        .tracking(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 底部信息
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(hex: "E5E5E5"))
                            .padding(.vertical, Spacing.md)
                        
                        HStack {
                            Text(poem.authorName)
                                .font(.system(size: 12, weight: .ultraLight))
                                .foregroundColor(Color(hex: "ABABAB"))
                            
                            Spacer()
                            
                            Text("山海诗馆")
                                .font(.system(size: 11, weight: .ultraLight, design: .serif))
                                .foregroundColor(Color(hex: "ABABAB"))
                                .tracking(2)
                        }
                    }
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 64)
                
                Spacer()
            }
        }
        .frame(width: 350, height: 500)
        .cornerRadius(8)
        .shadow(color: Colors.textInk.opacity(0.08), radius: 20, x: 0, y: 8)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: Spacing.md) {
            // 保存到相册
            Button(action: saveToPhotos) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .light))
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
                        .font(.system(size: 16, weight: .light))
                    Text("分享图片")
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
        guard let image = renderPoemAsImage() else {
            alertMessage = "图片生成失败，请重试"
            showingSaveAlert = true
            return
        }
        
        // 保存到相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        alertMessage = "图片已保存到相册"
        showingSaveAlert = true
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func shareImage() {
        guard let image = renderPoemAsImage() else {
            alertMessage = "图片生成失败，请重试"
            showingSaveAlert = true
            return
        }
        
        // 使用系统分享
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
    
    private func renderPoemAsImage() -> UIImage? {
        // 创建渲染器
        let renderer = ImageRenderer(content: poemTemplate)
        renderer.scale = 3.0 // 3x 分辨率，确保清晰
        
        return renderer.uiImage
    }
}

