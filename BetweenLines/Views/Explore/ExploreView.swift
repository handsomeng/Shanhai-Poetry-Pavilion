//
//  ExploreView.swift
//  山海诗馆
//
//  赏诗主视图：浏览广场诗歌
//

import SwiftUI

struct ExploreView: View {
    
    // 后端服务
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    @StateObject private var interactionService = InteractionService.shared
    
    // UI 状态
    @State private var selectedFilter: FilterType = .latest
    @State private var showLoginSheet = false
    
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if authService.isAuthenticated {
                        // 已登录，显示用户名
                        Text(authService.currentProfile?.username ?? "")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                    } else {
                        // 未登录，显示登录按钮
                        Button("登录") {
                            showLoginSheet = true
                        }
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.accentTeal)
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .task {
                // 加载广场诗歌
                await loadPoems()
            }
            .refreshable {
                // 下拉刷新
                await loadPoems()
            }
        }
    }
    
    // MARK: - Load Poems
    
    private func loadPoems() async {
        do {
            switch selectedFilter {
            case .latest:
                try await poemService.fetchSquarePoems(limit: 50)
            case .popular:
                try await poemService.fetchPopularPoems(limit: 50)
            case .random:
                try await poemService.fetchSquarePoems(limit: 50)
            }
        } catch {
            print("加载诗歌失败: \(error)")
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
        HStack(spacing: Spacing.sm) {
            ForEach(FilterType.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    Task {
                        await loadPoems()
                    }
                }) {
                    Text(filter.rawValue)
                        .font(Fonts.bodyRegular())
                        .foregroundColor(selectedFilter == filter ? .white : Colors.textInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedFilter == filter ? Colors.accentTeal : Colors.white)
                        .cornerRadius(CornerRadius.medium)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Poems List
    
    private var poemsListSection: some View {
        ScrollView {
            if filteredPoems.isEmpty {
                // 空状态视图
                emptyStateView
            } else {
                    LazyVStack(spacing: Spacing.lg) {
                        ForEach(filteredPoems) { poem in
                            NavigationLink(destination: PoemDetailView(poem: poem)) {
                                PoemCardView(poem: poem)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .cardButtonStyle()
                        }
                    }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: "book.closed")
                .font(.system(size: 64, weight: .thin))
                .foregroundColor(Colors.textQuaternary)
            
            VStack(spacing: Spacing.sm) {
                Text("还没有诗歌")
                    .font(Fonts.titleLarge())
                    .foregroundColor(Colors.textInk)
                
                Text("成为第一个创作者吧")
                    .font(Fonts.body())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxl)
    }
    
    // MARK: - Computed Properties
    
    private var filteredPoems: [Poem] {
        let poems = poemService.squarePoems.map { $0.toLocalPoem() }
        
        switch selectedFilter {
        case .latest, .popular:
            return poems
        case .random:
            return poems.shuffled()
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
                    Text("\(poem.squareLikeCount)")
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

