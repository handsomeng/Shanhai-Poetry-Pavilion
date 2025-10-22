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
                    
                    // 标签
                    if !poem.tags.isEmpty {
                        tagsSection
                    }
                    
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
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(poem.tags, id: \.self) { tag in
                    Text(tag)
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.accentTeal)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Colors.accentTeal.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
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
        HStack(spacing: Spacing.xl) {
            // 点赞
            Button(action: {
                poemManager.toggleLike(for: poem)
                if let updated = poemManager.getPoem(by: poem.id) {
                    poem = updated
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: poem.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(poem.isLiked ? .red : Colors.textSecondary)
                    
                    Text("\(poem.likeCount)")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            // 收藏
            Button(action: {
                poemManager.toggleFavorite(for: poem)
                if let updated = poemManager.getPoem(by: poem.id) {
                    poem = updated
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: poem.isFavorited ? "star.fill" : "star")
                        .font(.system(size: 24))
                        .foregroundColor(poem.isFavorited ? Colors.accentTeal : Colors.textSecondary)
                    
                    Text(poem.isFavorited ? "已收藏" : "收藏")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // 统计信息
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 12))
                    Text("\(poem.wordCount) 字")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 12))
                    Text("\(poem.lineCount) 行")
                }
            }
            .font(Fonts.footnote())
            .foregroundColor(Colors.textSecondary)
        }
        .padding(Spacing.lg)
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


