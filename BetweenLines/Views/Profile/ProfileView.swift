//
//  ProfileView.swift
//  山海诗馆
//
//  我的主页：个人诗歌管理
//

import SwiftUI

struct ProfileView: View {
    
    // 本地服务
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var identityService = UserIdentityService()
    
    // UI 状态
    @State private var showingSettings = false
    @State private var showingSubscription = false
    @State private var showingMembershipDetail = false
    @State private var showingPoetTitle = false
    
    // 显示的用户名
    private var displayUsername: String {
        return identityService.penName.isEmpty ? "山海诗人" : identityService.penName
    }
    
    // 用户序号（基于设备 ID 生成一个稳定的数字）
    private var userNumber: String {
        let hashValue = abs(identityService.userId.hashValue)
        return String(hashValue % 100000 + 1) // 1-100000 之间的数字
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // 头部信息
                        headerSection
                        
                        // 会员状态卡片
                        membershipCard
                        
                        // 统计数据（可点击跳转到诗集）
                        statsSection
                        
                        // 诗人等级（可点击查看详情）
                        poetTitleSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Spacing.lg)
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
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showingMembershipDetail) {
                MembershipDetailView()
            }
            .sheet(isPresented: $showingPoetTitle) {
                PoetTitleView(poemCount: poemManager.allPoems.count)
            }
        }
        // 移除删除诗歌的 alert（诗歌管理已移到【诗集】Tab）
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            // 左侧：笔名 + 称号
            HStack(alignment: .center, spacing: Spacing.sm) {
                // 笔名
                Text(displayUsername)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(Colors.textInk)
                
                // 称号标签（可点击查看详情）
                Button(action: {
                    showingPoetTitle = true
                }) {
                    HStack(spacing: 4) {
                        Text(currentPoetTitle)
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Colors.textSecondary.opacity(0.5))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Colors.textSecondary.opacity(0.08))
                    .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)  // 顶部间距
        .padding(.bottom, Spacing.sm)  // 增加底部间距，与会员卡片拉开距离
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
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)  // 缩小垂直间距
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
                            
                            Text("免费试用 7 天，随时可退款")
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
                    .padding(.vertical, Spacing.sm)  // 缩小垂直间距
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
            .padding(.bottom, Spacing.sm)  // 增加底部间距，与 Tab 拉开距离
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
            
            // 草稿统计已移除，统一显示在"诗歌"中
            
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
    
    // MARK: - Poet Title Section
    
    private var poetTitleSection: some View {
        Button(action: { showingPoetTitle = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("诗人等级")
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textSecondary)
                    
                    Text(poemManager.currentPoetTitle.displayName)
                        .font(Fonts.titleMedium())
                        .foregroundColor(Colors.accentTeal)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Colors.textTertiary)
            }
            .padding(Spacing.lg)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    
    /// 当前诗人称号
    private var currentPoetTitle: String {
        let poemCount = poemManager.myStats.totalPoems
        return PoetTitle.title(forPoemCount: poemCount).displayName
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
                HStack(spacing: 8) {
                    Text(poem.title.isEmpty ? "无标题" : poem.title)
                        .font(Fonts.bodyLarge())
                        .foregroundColor(Colors.textInk)
                        .lineLimit(1)
                    
                    // 审核状态角标
                    if poem.auditStatus != .published {
                        auditStatusBadge
                    }
                }
                
                Text(poem.shortDate)
                    .font(Fonts.captionSmall())
                    .foregroundColor(Colors.textSecondary)
                
                // 被驳回时显示原因
                if poem.auditStatus == .rejected, let reason = poem.rejectionReason {
                    Text("驳回原因：\(reason)")
                        .font(Fonts.captionSmall())
                        .foregroundColor(.red)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // 仅已通过时显示点赞数
            if poem.auditStatus == .published {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Text("\(poem.squareLikeCount)")
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var auditStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(poem.auditStatus.description)
                .font(Fonts.captionSmall())
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(CornerRadius.small)
    }
    
    private var statusColor: Color {
        switch poem.auditStatus {
        case .notPublished:
            return Colors.textSecondary
        case .published:
            return .green
        case .pending:
            return .orange
        case .rejected:
            return .red
        }
    }
}

// MARK: - My Poem Card

private struct MyPoemCard: View {
    let poem: Poem
    
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            // 左侧：标题
            Text(poem.title.isEmpty ? "无标题" : poem.title)
                .font(Fonts.bodyLarge())
                .foregroundColor(Colors.textInk)
                .lineLimit(1)
            
            Spacer()
            
            // 右侧：时间
            Text(poem.shortDate)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
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

