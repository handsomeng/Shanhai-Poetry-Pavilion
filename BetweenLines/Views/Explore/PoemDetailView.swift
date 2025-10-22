//
//  PoemDetailView.swift
//  山海诗馆
//
//  诗歌详情页
//

import SwiftUI

struct PoemDetailView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State var poem: Poem
    @State private var likeScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 诗歌头部信息
                    headerSection
                    
                    // 诗歌内容
                    contentSection
                    
                    // AI 点评
                    if let aiComment = poem.aiComment {
                        aiCommentSection(comment: aiComment)
                    }
                    
                    // 底部操作区
                    actionSection
                    
                    Spacer()
                        .frame(height: Spacing.xl)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
            }
        }
        .navigationTitle("诗歌详情")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(poem.title)
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            HStack {
                Text(poem.authorName)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Text(poem.formattedDate)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        Text(poem.content)
            .font(Fonts.bodyPoem())
            .foregroundColor(Colors.textInk)
            .lineSpacing(10)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
    }
    
    // MARK: - AI Comment Section
    
    private func aiCommentSection(comment: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Colors.accentTeal)
                Text("AI 诗评")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
            }
            
            Text(comment)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(6)
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
    }
    
    // MARK: - Action Section
    
    private var actionSection: some View {
        HStack {
            Spacer()
            
            // 点赞（居中）
            Button(action: {
                // 触发动画
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    likeScale = 1.3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        likeScale = 1.0
                    }
                }
                
                // 更新状态
                poemManager.toggleLike(for: poem)
                if let updated = poemManager.getPoem(by: poem.id) {
                    poem = updated
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: poem.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 28))
                        .foregroundColor(poem.isLiked ? .red : Colors.textSecondary)
                        .scaleEffect(likeScale)
                    
                    Text("\(poem.likeCount)")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PoemDetailView(poem: .example)
    }
}


