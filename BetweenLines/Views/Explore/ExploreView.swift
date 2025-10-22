//
//  ExploreView.swift
//  山海诗馆
//
//  赏诗主视图：浏览广场诗歌
//

import SwiftUI

struct ExploreView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State private var selectedFilter: FilterType = .latest
    
    enum FilterType: String, CaseIterable {
        case latest = "最新"
        case popular = "热门"
        case random = "随机"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部
                    headerSection
                    
                    // 筛选条件
                    filterSection
                    
                    // 诗歌列表
                    poemsListSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("赏诗")
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text("欣赏他人的诗歌创作")
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(selectedFilter == filter ? .white : Colors.textInk)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                            .background(selectedFilter == filter ? Colors.accentTeal : Colors.white)
                            .cornerRadius(CornerRadius.medium)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Poems List
    
    private var poemsListSection: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                ForEach(filteredPoems) { poem in
                    NavigationLink(destination: PoemDetailView(poem: poem)) {
                        PoemCardView(poem: poem)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredPoems: [Poem] {
        switch selectedFilter {
        case .latest:
            return poemManager.explorePoems
        case .popular:
            return poemManager.popularPoems
        case .random:
            return poemManager.explorePoems.shuffled()
        }
    }
}

// MARK: - Poem Card View

private struct PoemCardView: View {
    let poem: Poem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题和作者
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title)
                        .font(Fonts.titleMedium())
                        .foregroundColor(Colors.textInk)
                    
                    Text(poem.authorName)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
            }
            
            // 诗歌内容
            Text(poem.content)
                .font(Fonts.bodyPoem())
                .foregroundColor(Colors.textInk)
                .lineSpacing(6)
                .lineLimit(6)
            
            // 底部信息
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: poem.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(poem.isLiked ? .red : Colors.textSecondary)
                    Text("\(poem.likeCount)")
                        .font(Fonts.footnote())
                }
                
                Spacer()
                
                Text(poem.shortDate)
                    .font(Fonts.footnote())
                    .foregroundColor(Colors.textSecondary)
            }
            .foregroundColor(Colors.textSecondary)
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("赏诗主页") {
    ExploreView()
}

