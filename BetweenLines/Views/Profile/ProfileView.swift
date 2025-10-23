//
//  ProfileView.swift
//  山海诗馆
//
//  我的主页：个人诗歌管理
//

import SwiftUI

struct ProfileView: View {
    
    // 后端服务
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    
    // 本地服务（用于收藏和会员）
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    // UI 状态
    @State private var selectedTab: ProfileTab = .collection
    @State private var poemToDelete: Poem?
    @State private var showingDeleteAlert = false
    @State private var showingSettings = false
    @State private var showingSubscription = false
    @State private var showingMembershipDetail = false
    @State private var showingPoetTitle = false
    @State private var showingLogin = false
    @State private var showingLogoutConfirm = false
    @State private var myPublishedPoems: [Poem] = []
    @State private var myDraftPoems: [Poem] = []
    
    enum ProfileTab: String, CaseIterable {
        case collection = "诗集"
        case drafts = "草稿"
        case published = "已发布"
    }
    
    // 显示的用户名（优先使用本地笔名）
    private var displayUsername: String {
        if authService.isAuthenticated {
            // 如果云端用户名是默认格式（诗人+数字），优先使用本地笔名
            let cloudUsername = authService.currentProfile?.username ?? ""
            let localPenName = UserDefaults.standard.string(forKey: "penName") ?? ""
            
            if cloudUsername.hasPrefix("诗人") && !localPenName.isEmpty {
                return localPenName
            } else {
                return cloudUsername.isEmpty ? poemManager.currentUserName : cloudUsername
            }
        } else {
            return poemManager.currentUserName
        }
    }
    
    // 用户序号（基于用户ID后6位）
    private var userNumber: String {
        if authService.isAuthenticated, let userId = authService.currentUser?.id {
            // 从 UUID 中提取数字
            let numbers = userId.filter { $0.isNumber }
            if numbers.count >= 6 {
                let lastSix = String(numbers.suffix(6))
                return lastSix
            }
        }
        return "000001"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部信息
                    headerSection
                    
                    // 会员状态卡片
                    membershipCard
                    
                    // 选项卡
                    tabSection
                    
                    // 诗歌列表
                    poemsListSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Spacing.md) {
                        // 设置按钮
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .ultraLight))
                                .foregroundColor(Colors.textSecondary)
                        }
                        
                        // 登出按钮（仅已登录时显示）
                        if authService.isAuthenticated {
                            Button(action: {
                                showingLogoutConfirm = true
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18, weight: .ultraLight))
                                    .foregroundColor(Colors.error)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showingMembershipDetail) {
                MembershipDetailView()
            }
            .sheet(isPresented: $showingPoetTitle) {
                PoetTitleView()
            }
            .sheet(isPresented: $showingLogin) {
                LoginView()
            }
            .alert("确认退出登录", isPresented: $showingLogoutConfirm) {
                Button("取消", role: .cancel) { }
                Button("退出", role: .destructive) {
                    authService.signOut()
                }
            } message: {
                Text("退出后将无法发布诗歌和使用互动功能")
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert, presenting: poemToDelete) { poem in
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deletePoem(poem)
            }
        } message: { poem in
            Text("确定要删除《\(poem.title)》吗？")
        }
        .task {
            // 加载用户诗歌
            if authService.isAuthenticated {
                await loadUserPoems()
            }
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            if newValue {
                Task {
                    await loadUserPoems()
                }
            } else {
                myPublishedPoems = []
                myDraftPoems = []
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if authService.isAuthenticated {
                Task {
                    await loadUserPoems()
                }
            }
        }
    }
    
    // MARK: - Load User Poems
    
    private func loadUserPoems() async {
        guard let userId = authService.currentUser?.id else { return }
        
        do {
            try await poemService.fetchMyPoems(authorId: userId)
            
            // 分类为草稿和已发布
            let allPoems = poemService.myPoems
            myDraftPoems = allPoems.filter { !$0.isPublic }.map { $0.toLocalPoem(authorName: authService.currentProfile?.username ?? "我") }
            myPublishedPoems = allPoems.filter { $0.isPublic }.map { $0.toLocalPoem(authorName: authService.currentProfile?.username ?? "我") }
        } catch {
            print("加载用户诗歌失败: \(error)")
        }
    }
    
    // MARK: - Delete Poem
    
    private func deletePoem(_ poem: Poem) {
        if authService.isAuthenticated && (selectedTab == .drafts || selectedTab == .published) {
            // 后端删除
            Task {
                do {
                    try await poemService.deletePoem(id: poem.id)
                    await loadUserPoems()
                } catch {
                    print("删除失败: \(error)")
                }
            }
        } else {
            // 本地删除（诗集）
            poemManager.deletePoem(poem)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 第一行：笔名 + 会员/登录按钮
            HStack(alignment: .center, spacing: Spacing.sm) {
                // 大字笔名
                Text(displayUsername)
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundColor(Colors.textInk)
                
                // 会员标识
                if authService.isAuthenticated && subscriptionManager.isSubscribed {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "D4AF37"))
                }
                
                Spacer()
                
                // 登录按钮（仅未登录时显示）
                if !authService.isAuthenticated {
                    Button("登录") {
                        showingLogin = true
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.accentTeal)
                }
            }
            
            // 第二行：标签（称号 · 序号）
            HStack(spacing: Spacing.sm) {
                // 称号标签
                TagView(text: authService.currentProfile?.poetTitle ?? poemManager.currentPoetTitle.displayName)
                
                // 序号标签
                TagView(text: "第 \(userNumber) 位山海诗人")
            }
            
            // 第三行：统计信息（可点击查看称号详情）
            Button(action: {
                if authService.isAuthenticated {
                    // 已登录：显示称号详情
                    showingPoetTitle = true
                } else {
                    // 未登录：提示登录
                    showingLogin = true
                }
            }) {
                HStack(spacing: 4) {
                    if authService.isAuthenticated, let profile = authService.currentProfile {
                        // 后端数据
                        Text("已写 \(profile.totalPoems) 首诗，获得 \(profile.totalLikes) 个赞")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textSecondary)
                    } else {
                        // 本地数据
                        let stats = poemManager.myStats
                        Text("已写 \(stats.totalPoems) 首诗，获得 \(stats.totalLikes) 个赞")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    // 箭头指示可点击
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Colors.textSecondary.opacity(0.4))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Membership Card
    
    private var membershipCard: some View {
        Group {
            if subscriptionManager.isSubscribed {
                // ===== 已订阅：可点击查看详情 =====
                Button(action: {
                    showingMembershipDetail = true
                }) {
                    HStack(alignment: .center, spacing: Spacing.md) {
                        // 左侧金色皇冠
                        Image(systemName: "crown.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "D4AF37"))
                        
                        // 中间文案
                        VStack(alignment: .leading, spacing: 4) {
                            Text("山海已在你心间")
                                .font(Fonts.bodyLarge())
                                .foregroundColor(Color(hex: "B8860B"))
                                .fixedSize(horizontal: true, vertical: false)
                            
                            if let subscription = subscriptionManager.currentSubscription {
                                HStack(spacing: 4) {
                                    Text("\(subscription.displayName)订阅")
                                        .font(Fonts.caption())
                                        .foregroundColor(Colors.textSecondary)
                                    
                                    Text("·")
                                        .font(Fonts.caption())
                                        .foregroundColor(Colors.textSecondary.opacity(0.5))
                                    
                                    Text("到期 \(subscriptionManager.expirationDateString)")
                                        .font(Fonts.caption())
                                        .foregroundColor(Colors.textSecondary)
                                }
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        
                        Spacer()
                        
                        // 右侧箭头
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "D4AF37").opacity(0.4))
                    }
                    .padding(Spacing.lg)
                }
                .buttonStyle(PlainButtonStyle())
                
            } else {
                // ===== 未订阅：紧凑布局 =====
                Button(action: {
                    showingSubscription = true
                }) {
                    HStack(spacing: Spacing.md) {
                        // 左侧皇冠
                        Image(systemName: "crown")
                            .font(.system(size: 18))
                            .foregroundColor(Colors.textSecondary)
                        
                        // 中间文案
                        VStack(alignment: .leading, spacing: 2) {
                            Text("升级会员")
                                .font(Fonts.bodyRegular())
                                .foregroundColor(Colors.textInk)
                            
                            Text("解锁全部高级功能")
                                .font(.system(size: 12))
                                .foregroundColor(Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // 右侧按钮文字
                        Text("立即订阅")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.accentTeal)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Colors.accentTeal.opacity(0.6))
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
            .background(
                LinearGradient(
                    colors: subscriptionManager.isSubscribed
                        ? [Color(hex: "FFF8E7"), Color(hex: "FFFBF0")]  // 淡金色渐变
                        : [Colors.white, Colors.white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(subscriptionManager.isSubscribed ? Color(hex: "D4AF37").opacity(0.2) : Color.clear, lineWidth: 1.5)  // 金色边框
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .scaleButtonStyle()
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.md)
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
            // 诗集：继续使用本地收藏
            return poemManager.myCollection
        case .drafts:
            // 草稿：使用后端数据（如果已登录）
            return authService.isAuthenticated ? myDraftPoems : poemManager.myDrafts
        case .published:
            // 已发布：使用后端数据（如果已登录）
            return authService.isAuthenticated ? myPublishedPoems : poemManager.myPublishedToSquare
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
                    Text("\(poem.squareLikeCount)")
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

// MARK: - Tag View

/// 淡淡的标签视图
struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Colors.textSecondary.opacity(0.08))
            .cornerRadius(5)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}

