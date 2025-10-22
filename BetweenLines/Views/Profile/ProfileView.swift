//
//  ProfileView.swift
//  山海诗馆
//
//  我的主页：个人诗歌管理
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State private var selectedTab: ProfileTab = .collection
    @State private var poemToDelete: Poem?
    @State private var showingDeleteAlert = false
    @State private var showingSettings = false
    
    enum ProfileTab: String, CaseIterable {
        case collection = "诗集"
        case drafts = "草稿"
        case published = "已发布"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部信息
                    headerSection
                    
                    // 选项卡
                    tabSection
                    
                    // 诗歌列表
                    poemsListSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert, presenting: poemToDelete) { poem in
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                poemManager.deletePoem(poem)
            }
        } message: { poem in
            Text("确定要删除《\(poem.title)》吗？")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 6) {
            Text("诗人")
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textSecondary)
            
            Text("·")
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textSecondary)
            
            Text(String(poemManager.currentUserName.prefix(7)))
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(poemManager.myStats.totalPoems)",
                label: "作品"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: "\(poemManager.myStats.totalDrafts)",
                label: "草稿"
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: "\(poemManager.myStats.totalLikes)",
                label: "获赞"
            )
        }
        .padding(.vertical, Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .padding(.horizontal, Spacing.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Tab Section
    
    private var tabSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Text(tab.rawValue)
                                .font(Fonts.bodyRegular())
                                .foregroundColor(selectedTab == tab ? Colors.accentTeal : Colors.textSecondary)
                            
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Colors.accentTeal)
                                    .frame(height: 2)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Poems List
    
    private var poemsListSection: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(currentPoems) { poem in
                    NavigationLink(destination: destinationView(for: poem)) {
                        if selectedTab == .published {
                            PublishedPoemCard(poem: poem)
                        } else {
                            MyPoemCard(
                                poem: poem,
                                onDelete: {
                                    poemToDelete = poem
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if currentPoems.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 48))
                .foregroundColor(Colors.textSecondary.opacity(0.5))
            
            Text(emptyStateText)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
        .padding(.top, Spacing.xxl)
    }
    
    // MARK: - Computed Properties
    
    private var currentPoems: [Poem] {
        switch selectedTab {
        case .collection:
            return poemManager.myCollection
        case .drafts:
            return poemManager.myDrafts
        case .published:
            return poemManager.myPublishedToSquare
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case .collection: return "doc.text"
        case .drafts: return "doc.plaintext"
        case .published: return "square.and.arrow.up"
        }
    }
    
    private var emptyStateText: String {
        switch selectedTab {
        case .collection: return "还没有保存作品"
        case .drafts: return "没有草稿"
        case .published: return "还没有发布到广场"
        }
    }
    
    private func destinationView(for poem: Poem) -> some View {
        Group {
            if selectedTab == .published {
                // 已发布的诗歌跳转到广场详情页
                PoemDetailView(poem: poem)
            } else {
                // 诗集和草稿跳转到新的编辑详情页
                PoemEditorDetailView(poem: poem)
            }
        }
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
            
            Text(label)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Published Poem Card（已发布到广场的诗歌卡片）

private struct PublishedPoemCard: View {
    let poem: Poem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(poem.title.isEmpty ? "无标题" : poem.title)
                    .font(Fonts.bodyLarge())
                    .foregroundColor(Colors.textInk)
                    .lineLimit(1)
                
                Text(poem.shortDate)
                    .font(Fonts.captionSmall())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                Text("\(poem.squareLikeCount)")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - My Poem Card

private struct MyPoemCard: View {
    let poem: Poem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题和作者
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title.isEmpty ? "无标题" : poem.title)
                        .font(Fonts.bodyLarge())
                        .foregroundColor(Colors.textInk)
                    
                    Text(poem.authorName)
                        .font(Fonts.captionSmall())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(Colors.error)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 诗歌内容
            Text(poem.content)
                .font(Fonts.body())
                .foregroundColor(Colors.textInk)
                .lineSpacing(4)
                .lineLimit(4)
            
            // 底部信息
            HStack {
                HStack(spacing: 4) {
                    if poem.isLiked {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                            .foregroundColor(Colors.textSecondary)
                    }
                    Text("\(poem.likeCount)")
                        .font(Fonts.footnote())
                }
                .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Text(poem.shortDate)
                    .font(Fonts.footnote())
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}

