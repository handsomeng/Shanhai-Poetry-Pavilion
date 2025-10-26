//
//  PoetryCollectionView.swift
//  山海诗馆
//
//  【诗集】Tab 主界面
//  - 诗歌列表（诗集/草稿/已发布）
//  - 右上角【+】创作按钮
//  - 搜索功能
//

import SwiftUI

struct PoetryCollectionView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State private var selectedTab: CollectionTab = .collection
    @State private var showCreateModeSelector = false
    @State private var showSearch = false
    
    enum CollectionTab: String, CaseIterable, Identifiable {
        case collection = "诗集"
        case drafts = "草稿"
        case published = "已发布"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab 切换
                tabSwitcher
                
                // 诗歌列表
                poemsList
            }
            .background(Colors.backgroundCream)
            .navigationTitle("诗集")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // 搜索按钮
                        Button(action: { showSearch = true }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Colors.textSecondary)
                        }
                        
                        // 创作按钮
                        Button(action: { showCreateModeSelector = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Colors.accentTeal)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateModeSelector) {
                CreateModeSelectorView()
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
        }
    }
    
    // MARK: - Tab Switcher
    
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(CollectionTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(selectedTab == tab ? Colors.accentTeal : Colors.textSecondary)
                        
                        // 下划线
                        Rectangle()
                            .fill(selectedTab == tab ? Colors.accentTeal : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Poems List
    
    private var poemsList: some View {
        Group {
            if currentPoems.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(currentPoems) { poem in
                            NavigationLink(destination: MyPoemDetailView(poem: poem, isDraft: isDraft(poem))) {
                                PoemCard(poem: poem, isNew: isNewPoem(poem))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(Colors.textTertiary)
            
            Text(emptyStateText)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("点击右上角 + 开始创作")
                .font(Fonts.caption())
                .foregroundColor(Colors.textTertiary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
    }
    
    private var emptyStateText: String {
        switch selectedTab {
        case .collection:
            return "还没有诗歌"
        case .drafts:
            return "还没有草稿"
        case .published:
            return "还没有发布到广场的诗"
        }
    }
    
    // MARK: - Helpers
    
    private var currentPoems: [Poem] {
        switch selectedTab {
        case .collection:
            return poemManager.myCollection.sorted { $0.createdAt > $1.createdAt }
        case .drafts:
            return poemManager.myDrafts.sorted { $0.createdAt > $1.createdAt }
        case .published:
            return poemManager.myPublishedToSquare.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    /// 判断是否是新诗（5秒内创建）
    private func isNewPoem(_ poem: Poem) -> Bool {
        Date().timeIntervalSince(poem.createdAt) < 5
    }
    
    /// 判断是否是草稿
    private func isDraft(_ poem: Poem) -> Bool {
        !poem.inMyCollection && !poem.inSquare
    }
}

// MARK: - Poem Card

struct PoemCard: View {
    
    let poem: Poem
    let isNew: Bool
    
    @State private var isHighlighted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .lineLimit(1)
            }
            
            // 内容预览
            Text(poem.content)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .lineLimit(2)
            
            // 时间戳
            Text(poem.shortDate)
                .font(Fonts.caption())
                .foregroundColor(Colors.textTertiary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.white)
        .cornerRadius(CornerRadius.medium)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(isHighlighted ? Colors.accentTeal : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isHighlighted ? 1.02 : 1.0)
        .onAppear {
            // 如果是新诗，显示高亮动画
            if isNew {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isHighlighted = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isHighlighted = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PoetryCollectionView()
}

