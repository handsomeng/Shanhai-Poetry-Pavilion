//
//  ExploreView.swift
//  山海诗馆
//
//  赏诗主视图：浏览所有人发布的诗歌
//

import SwiftUI

struct ExploreView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                if squarePoems.isEmpty {
                    emptyStateView
                } else {
                    poemsListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("赏诗")
                        .font(Fonts.h2Small())
                        .foregroundColor(Colors.textInk)
                }
            }
        }
    }
    
    // MARK: - Poems List
    
    private var poemsListView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(squarePoems) { poem in
                    NavigationLink(destination: PoemDetailView(poem: poem)) {
                        SquarePoemCard(poem: poem)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 80))
                .foregroundColor(Colors.textInk.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("广场还很空")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                
                Text("去创作一首诗，分享到广场吧")
                    .font(Fonts.body())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var squarePoems: [Poem] {
        // 获取所有发布到广场的诗歌（包括自己和其他人的）
        return poemManager.explorePoems
    }
}

// MARK: - Square Poem Card

/// 广场诗歌卡片（带点赞数）
private struct SquarePoemCard: View {
    let poem: Poem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题和作者
            VStack(alignment: .leading, spacing: 4) {
                Text(poem.title.isEmpty ? "无标题" : poem.title)
                    .font(Fonts.bodyLarge())
                    .foregroundColor(Colors.textInk)
                
                Text(poem.authorName)
                    .font(Fonts.captionSmall())
                    .foregroundColor(Colors.textSecondary)
            }
            
            // 诗歌内容
            Text(poem.content)
                .font(Fonts.body())
                .foregroundColor(Colors.textInk)
                .lineSpacing(4)
                .lineLimit(4)
            
            // 底部信息：日期 + 点赞数
            HStack {
                Text(poem.shortDate)
                    .font(Fonts.footnote())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                // 点赞数
                HStack(spacing: 4) {
                    Image(systemName: poem.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(poem.isLiked ? .red : Colors.textSecondary)
                    
                    Text("\(poem.squareLikeCount)")
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ExploreView()
}
