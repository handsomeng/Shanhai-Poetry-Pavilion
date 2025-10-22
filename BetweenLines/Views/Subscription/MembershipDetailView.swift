//
//  MembershipDetailView.swift
//  山海诗馆
//
//  会员详情页（已订阅用户）
//

import SwiftUI

struct MembershipDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 会员状态卡片
                        membershipStatusCard
                        
                        // 会员权益
                        benefitsSection
                        
                        // 管理订阅说明
                        managementSection
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xl)
                }
            }
            .navigationTitle("会员中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Membership Status Card
    
    private var membershipStatusCard: some View {
        VStack(spacing: Spacing.lg) {
            // 皇冠图标
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "D4AF37"))
            
            // 会员标题
            Text("山海已在你心间")
                .font(Fonts.h2())
                .foregroundColor(Color(hex: "B8860B"))
            
            // 订阅信息
            if let subscription = subscriptionManager.currentSubscription {
                VStack(spacing: Spacing.xs) {
                    HStack(spacing: 8) {
                        Text("\(subscription.displayName)会员")
                            .font(Fonts.bodyLarge())
                            .foregroundColor(Colors.textInk)
                        
                        Text("·")
                            .foregroundColor(Colors.textSecondary.opacity(0.5))
                        
                        Text("到期 \(subscriptionManager.expirationDateString)")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    Text("自动续费已开启")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(
            LinearGradient(
                colors: [Color(hex: "FFF8E7"), Color(hex: "FFFBF0")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .stroke(Color(hex: "D4AF37").opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "D4AF37").opacity(0.1), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("会员权益")
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textInk)
                .padding(.horizontal, Spacing.sm)
            
            VStack(alignment: .leading, spacing: Spacing.md) {
                ForEach(MemberBenefit.allCases, id: \.self) { benefit in
                    HStack(spacing: Spacing.md) {
                        Image(systemName: benefit.icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "D4AF37"))
                            .frame(width: 24)
                        
                        Text(benefit.rawValue)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textInk)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Colors.accentTeal)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Management Section
    
    private var managementSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("订阅管理")
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textInk)
                .padding(.horizontal, Spacing.sm)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                InfoRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "自动续费",
                    description: "订阅将在到期前自动续费"
                )
                
                InfoRow(
                    icon: "xmark.circle",
                    title: "取消订阅",
                    description: "可在 App Store 订阅管理中取消"
                )
                
                InfoRow(
                    icon: "dollarsign.circle",
                    title: "退款政策",
                    description: "订阅后立即生效，无法退款"
                )
                
                // 管理订阅按钮
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("在 App Store 中管理订阅")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.accentTeal)
                    .padding(Spacing.md)
                    .background(Colors.accentTeal.opacity(0.1))
                    .cornerRadius(CornerRadius.medium)
                }
                .scaleButtonStyle()
            }
            .padding(Spacing.lg)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Colors.textSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                
                Text(description)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    MembershipDetailView()
}

