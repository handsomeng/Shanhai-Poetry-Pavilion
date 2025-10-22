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
    
    let poem: Poem
    
    @State private var showingImageShare = false
    @State private var showingPublishSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 标题区域
                    titleSection
                    
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // 诗歌预览
                            poemPreview
                            
                            // 分享选项
                            shareOptions
                        }
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xxxl)
                    }
                }
            }
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
            .alert("发布成功", isPresented: $showingPublishSuccess) {
                Button("好的") {}
            } message: {
                Text("你的诗歌已发布到广场")
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(Colors.textInk)
            
            Text("分享你的诗歌")
                .font(Fonts.h2())
                .foregroundColor(Colors.textInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .background(Colors.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Colors.divider)
            , alignment: .bottom
        )
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
    
    // MARK: - Share Options
    
    private var shareOptions: some View {
        VStack(spacing: Spacing.lg) {
            // 分享到广场（推荐）
            if !poem.isPublished {
                shareToSquareButton
            } else {
                Text("已发布到广场")
                    .font(Fonts.body())
                    .foregroundColor(Colors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.cardBackground)
                    .cornerRadius(CornerRadius.medium)
            }
            
            // 生成图片分享
            shareAsImageButton
        }
        .padding(.horizontal, Spacing.lg)
    }
    
    private var shareToSquareButton: some View {
        Button(action: publishToSquare) {
            VStack(spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("分享到广场")
                                .font(Fonts.bodyLarge())
                                .foregroundColor(Colors.textInk)
                            
                            // 推荐标签
                            Text("推荐")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Colors.accentTeal)
                                .cornerRadius(3)
                        }
                        
                        Text("让更多人看到你的创作")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Colors.textQuaternary)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Colors.accentTeal, lineWidth: 1)
            )
        }
        .scaleButtonStyle()
    }
    
    private var shareAsImageButton: some View {
        Button(action: {
            showingImageShare = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("生成图片分享")
                        .font(Fonts.bodyLarge())
                        .foregroundColor(Colors.textInk)
                    
                    Text("分享到朋友圈或微信")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Colors.textQuaternary)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
        }
        .scaleButtonStyle()
    }
    
    // MARK: - Actions
    
    private func publishToSquare() {
        poemManager.publishPoem(poem)
        showingPublishSuccess = true
        
        // 延迟关闭，让用户看到成功提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

