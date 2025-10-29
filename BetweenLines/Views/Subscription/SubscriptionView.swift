//
//  SubscriptionView.swift
//  山海诗馆
//
//  会员订阅页面
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var toastManager = ToastManager.shared
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                if subscriptionManager.isLoading && subscriptionManager.products.isEmpty {
                    ProgressView("加载中...")
                        .font(Fonts.bodyRegular())
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // 标题
                            headerSection
                            
                            // 会员权益
                            benefitsSection
                            
                            // 订阅选项
                            subscriptionOptions
                            
                            // 购买按钮
                            purchaseButton
                            
                            // 恢复购买
                            restoreButton
                            
                            // 免责声明
                            disclaimer
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.xl)
                    }
                }
            }
            .navigationTitle("升级会员")
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
        .onAppear {
            if subscriptionManager.products.isEmpty {
                Task {
                    await subscriptionManager.loadProducts()
                    // 默认选中季卡（推荐）
                    selectedProduct = subscriptionManager.products.first { $0.id.contains("quarterly") }
                        ?? subscriptionManager.products.first
                }
            } else {
                selectedProduct = subscriptionManager.products.first { $0.id.contains("quarterly") }
                    ?? subscriptionManager.products.first
            }
        }
        .alert("购买失败", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(Colors.accentTeal)
            
            Text("免费试用 7 天")
                .font(Fonts.h2())
                .foregroundColor(Colors.textInk)
            
            Text("解锁全部高级功能，随时可退款")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
    
    // MARK: - Benefits
    
    private var benefitsSection: some View {
        VStack(spacing: Spacing.lg) {
            // 对比表格
            comparisonTable
            
            // 会员独享权益
            exclusiveBenefits
        }
    }
    
    // 对比表格
    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // 表头
            HStack(spacing: 0) {
                Text("功能")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("免费用户")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                    .frame(width: 80)
                
                Text("付费会员")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Colors.accentTeal)
                    .frame(width: 80)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Colors.backgroundCream)
            
            Divider()
            
            // 对比行
            comparisonRow(feature: "AI 点评", free: "3次/天", premium: "无限次")
            Divider().padding(.leading, Spacing.md)
            
            comparisonRow(feature: "AI 续写思路", free: "2次/天", premium: "无限次")
            Divider().padding(.leading, Spacing.md)
            
            comparisonRow(feature: "主题写诗", free: "1次/天", premium: "无限次")
            Divider().padding(.leading, Spacing.md)
            
            comparisonRow(feature: "临摹写诗", free: "1次/天", premium: "无限次")
            Divider().padding(.leading, Spacing.md)
            
            comparisonRow(feature: "图片模板", free: "基础", premium: "多种", isPremiumHighlighted: true)
            Divider().padding(.leading, Spacing.md)
            
            comparisonRow(feature: "会员标识", free: "—", premium: "👑", isPremiumHighlighted: true)
        }
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // 对比行
    private func comparisonRow(feature: String, free: String, premium: String, isPremiumHighlighted: Bool = false) -> some View {
        HStack(spacing: 0) {
            Text(feature)
                .font(.system(size: 15))
                .foregroundColor(Colors.textInk)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(free)
                .font(.system(size: 14))
                .foregroundColor(Colors.textSecondary)
                .frame(width: 80)
            
            Text(premium)
                .font(.system(size: 14, weight: isPremiumHighlighted ? .semibold : .regular))
                .foregroundColor(isPremiumHighlighted ? Colors.accentTeal : Colors.textInk)
                .frame(width: 80)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
    }
    
    // 会员独享权益（简化展示）
    private var exclusiveBenefits: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("会员独享")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Colors.textSecondary)
            
            HStack(spacing: Spacing.md) {
                benefitBadge(icon: "eye.slash", text: "无广告")
                benefitBadge(icon: "crown", text: "专属标识")
            }
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // 权益徽章
    private func benefitBadge(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Colors.accentTeal)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Colors.textInk)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Colors.accentTeal.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Subscription Options
    
    private var subscriptionOptions: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(subscriptionManager.products, id: \.id) { product in
                SubscriptionOptionCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    onTap: {
                        selectedProduct = product
                    }
                )
            }
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button(action: {
            Task {
                await purchaseSelectedProduct()
            }
        }) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "crown.fill")
                }
                
                Text(isPurchasing ? "处理中..." : "开始免费试用")
            }
            .font(Fonts.bodyLarge())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(
                LinearGradient(
                    colors: [Colors.accentTeal, Colors.accentTeal.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(CornerRadius.medium)
            .shadow(color: Colors.accentTeal.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .scaleButtonStyle()
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            Task {
                await restorePurchases()
            }
        }) {
            Text("恢复购买")
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
                .underline()
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Disclaimer
    
    private var disclaimer: some View {
        VStack(spacing: Spacing.xs) {
            Text("• 前 7 天免费试用，试用期内随时可退款")
            Text("• 试用结束后自动续费，可随时在设置中取消")
            Text("• 更多详情请查看用户协议和隐私政策")
        }
        .font(.system(size: 10))
        .foregroundColor(Colors.textTertiary)
        .multilineTextAlignment(.center)
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Actions
    
    private func purchaseSelectedProduct() async {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        
        do {
            try await subscriptionManager.purchase(product)
            await MainActor.run {
                isPurchasing = false
                toastManager.showSuccess("订阅成功！")
                
                // 延迟关闭页面
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        } catch let error as SubscriptionError {
            await MainActor.run {
                isPurchasing = false
                if error != .userCancelled {
                    errorMessage = error.errorDescription ?? "购买失败"
                    showingError = true
                }
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                errorMessage = "购买失败，请重试"
                showingError = true
            }
        }
    }
    
    private func restorePurchases() async {
        await subscriptionManager.restorePurchases()
        
        await MainActor.run {
            if subscriptionManager.isSubscribed {
                toastManager.showSuccess("已恢复订阅")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                toastManager.showError("未找到有效订阅")
            }
        }
    }
}

// MARK: - Subscription Option Card

private struct SubscriptionOptionCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    private var subscriptionType: SubscriptionType? {
        if product.id.contains("monthly") {
            return .monthly
        } else if product.id.contains("quarterly") {
            return .quarterly
        } else if product.id.contains("yearly") {
            return .yearly
        }
        return nil
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(subscriptionType?.displayName ?? "订阅")
                            .font(Fonts.bodyLarge())
                            .foregroundColor(Colors.textInk)
                        
                        if let badge = subscriptionType?.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Colors.accentTeal)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(subscriptionType?.description ?? "")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(Fonts.h2Small())
                        .foregroundColor(Colors.accentTeal)
                    
                    if subscriptionType == .quarterly || subscriptionType == .yearly {
                        let monthlyPrice = subscriptionType == .quarterly ? "¥6.6/月" : "¥5.8/月"
                        Text(monthlyPrice)
                            .font(.system(size: 11))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Colors.accentTeal : Colors.textSecondary.opacity(0.3))
            }
            .padding(Spacing.md)
            .background(Colors.white)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(isSelected ? Colors.accentTeal : Color.clear, lineWidth: 2)
            )
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleButtonStyle()
    }
}

// MARK: - Preview

#Preview {
    SubscriptionView()
}

