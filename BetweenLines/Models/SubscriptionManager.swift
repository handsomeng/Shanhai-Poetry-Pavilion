//
//  SubscriptionManager.swift
//  山海诗馆
//
//  订阅管理器
//

import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var currentSubscription: SubscriptionType?
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var expirationDate: Date?
    
    // AI 点评限额（免费用户 - 每周限制）
    @Published private(set) var weeklyAICommentCount: Int = 0
    private let maxFreeAIComments = 2
    
    // AI 续写灵感限额（免费用户 - 每周限制）
    @Published private(set) var weeklyInspirationCount: Int = 0
    private let maxFreeInspirations = 2
    
    // AI 主题思路限额（免费用户 - 每天限制）
    @Published private(set) var dailyThemeGuidanceCount: Int = 0
    private let maxFreeThemeGuidance = 2
    private let lastThemeGuidanceResetDateKey = "lastThemeGuidanceResetDate"
    
    // 主题写诗限额（免费用户 - 每周限制，已废弃）
    @Published private(set) var weeklyThemeWritingCount: Int = 0
    private let maxFreeThemeWriting = 2
    
    // 临摹写诗限额（免费用户 - 每周限制）
    @Published private(set) var weeklyMimicWritingCount: Int = 0
    private let maxFreeMimicWriting = 2
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - UserDefaults Keys
    
    private let lastResetDateKey = "lastWeeklyResetDate"
    private let aiCommentCountKey = "weeklyAICommentCount"
    private let inspirationCountKey = "weeklyInspirationCount"
    private let themeWritingCountKey = "weeklyThemeWritingCount"
    private let mimicWritingCountKey = "weeklyMimicWritingCount"
    private let subscriptionTypeKey = "subscriptionType"
    
    // MARK: - Initialization
    
    private init() {
        // 启动时检查订阅状态
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
            checkAndResetWeeklyLimit()
            checkAndResetDailyThemeGuidanceLimit()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        print("📱 [SubscriptionManager] Starting to load products...")
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = [
                SubscriptionType.monthly.productID,
                SubscriptionType.quarterly.productID,
                SubscriptionType.yearly.productID
            ]
            
            print("📱 [SubscriptionManager] Product IDs: \(productIDs)")
            
            products = try await Product.products(for: productIDs)
                .sorted { product1, product2 in
                    // 按价格排序：月卡 < 季卡 < 年卡
                    product1.price < product2.price
                }
            
            print("✅ [SubscriptionManager] Loaded \(products.count) products")
            for product in products {
                print("   - \(product.displayName): \(product.displayPrice) (\(product.id))")
            }
        } catch {
            print("❌ [SubscriptionManager] Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                // 订阅成功
                await updateSubscriptionStatus()
                await transaction.finish()
                return
            case .unverified:
                throw SubscriptionError.verificationFailed
            }
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            throw SubscriptionError.pending
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        var activeSubscription: SubscriptionType?
        var foundExpirationDate: Date?
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // 检查是否是有效订阅
                if let subscriptionType = subscriptionTypeFromProductID(transaction.productID) {
                    activeSubscription = subscriptionType
                    // 获取到期时间（StoreKit Testing 模拟）
                    foundExpirationDate = transaction.expirationDate
                    break
                }
            case .unverified:
                break
            }
        }
        
        isSubscribed = activeSubscription != nil
        currentSubscription = activeSubscription
        expirationDate = foundExpirationDate
        
        // 保存订阅状态
        if let subscription = activeSubscription {
            UserDefaults.standard.set(subscription.rawValue, forKey: subscriptionTypeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: subscriptionTypeKey)
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                case .unverified:
                    break
                }
            }
        }
    }
    
    // MARK: - AI Comment Limit
    
    /// 检查是否可以使用 AI 点评
    func canUseAIComment() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetWeeklyLimit()
        return weeklyAICommentCount < maxFreeAIComments
    }
    
    /// 使用一次 AI 点评
    func useAIComment() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        weeklyAICommentCount += 1
        UserDefaults.standard.set(weeklyAICommentCount, forKey: aiCommentCountKey)
    }
    
    /// 获取剩余 AI 点评次数
    func remainingAIComments() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeAIComments - weeklyAICommentCount)
    }
    
    /// 检查并重置每日限额
    private func checkAndResetWeeklyLimit() {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取本周一的0点（周的开始）
        let thisMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            // 检查上次重置是否在本周一之前
            if lastResetDate < thisMonday {
                // 新的一周，重置计数
                weeklyAICommentCount = 0
                weeklyInspirationCount = 0
                weeklyThemeWritingCount = 0
                weeklyMimicWritingCount = 0
                UserDefaults.standard.set(0, forKey: aiCommentCountKey)
                UserDefaults.standard.set(0, forKey: inspirationCountKey)
                UserDefaults.standard.set(0, forKey: themeWritingCountKey)
                UserDefaults.standard.set(0, forKey: mimicWritingCountKey)
                UserDefaults.standard.set(thisMonday, forKey: lastResetDateKey)
            } else {
                // 同一周，读取计数
                weeklyAICommentCount = UserDefaults.standard.integer(forKey: aiCommentCountKey)
                weeklyInspirationCount = UserDefaults.standard.integer(forKey: inspirationCountKey)
                weeklyThemeWritingCount = UserDefaults.standard.integer(forKey: themeWritingCountKey)
                weeklyMimicWritingCount = UserDefaults.standard.integer(forKey: mimicWritingCountKey)
            }
        } else {
            // 首次运行
            weeklyAICommentCount = 0
            weeklyInspirationCount = 0
            weeklyThemeWritingCount = 0
            weeklyMimicWritingCount = 0
            UserDefaults.standard.set(0, forKey: aiCommentCountKey)
            UserDefaults.standard.set(0, forKey: inspirationCountKey)
            UserDefaults.standard.set(0, forKey: themeWritingCountKey)
            UserDefaults.standard.set(0, forKey: mimicWritingCountKey)
            UserDefaults.standard.set(thisMonday, forKey: lastResetDateKey)
        }
    }
    
    // MARK: - AI Inspiration Limit
    
    /// 检查是否可以使用 AI 续写灵感
    func canUseInspiration() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetWeeklyLimit()
        return weeklyInspirationCount < maxFreeInspirations
    }
    
    /// 使用一次 AI 续写灵感
    func useInspiration() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        weeklyInspirationCount += 1
        UserDefaults.standard.set(weeklyInspirationCount, forKey: inspirationCountKey)
    }
    
    /// 获取剩余 AI 续写灵感次数
    func remainingInspirations() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeInspirations - weeklyInspirationCount)
    }
    
    // MARK: - AI Theme Guidance Limit (每天限制)
    
    /// 检查并重置每日限制（主题思路）
    private func checkAndResetDailyThemeGuidanceLimit() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastResetDate = UserDefaults.standard.object(forKey: lastThemeGuidanceResetDateKey) as? Date {
            // 检查是否是同一天
            if !calendar.isDate(lastResetDate, inSameDayAs: now) {
                // 不是同一天，重置计数
                dailyThemeGuidanceCount = 0
                UserDefaults.standard.set(0, forKey: "dailyThemeGuidanceCount")
                UserDefaults.standard.set(now, forKey: lastThemeGuidanceResetDateKey)
            } else {
                // 是同一天，加载计数
                dailyThemeGuidanceCount = UserDefaults.standard.integer(forKey: "dailyThemeGuidanceCount")
            }
        } else {
            // 首次使用，初始化
            dailyThemeGuidanceCount = 0
            UserDefaults.standard.set(0, forKey: "dailyThemeGuidanceCount")
            UserDefaults.standard.set(now, forKey: lastThemeGuidanceResetDateKey)
        }
    }
    
    /// 检查是否可以使用 AI 主题思路
    func canUseThemeGuidance() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetDailyThemeGuidanceLimit()
        return dailyThemeGuidanceCount < maxFreeThemeGuidance
    }
    
    /// 使用一次 AI 主题思路
    func useThemeGuidance() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        checkAndResetDailyThemeGuidanceLimit()
        dailyThemeGuidanceCount += 1
        UserDefaults.standard.set(dailyThemeGuidanceCount, forKey: "dailyThemeGuidanceCount")
    }
    
    /// 获取剩余 AI 主题思路次数
    func remainingThemeGuidance() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        checkAndResetDailyThemeGuidanceLimit()
        return max(0, maxFreeThemeGuidance - dailyThemeGuidanceCount)
    }
    
    // MARK: - Theme Writing Limit
    
    /// 检查是否可以使用主题写诗
    func canUseThemeWriting() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetWeeklyLimit()
        return weeklyThemeWritingCount < maxFreeThemeWriting
    }
    
    /// 使用一次主题写诗
    func useThemeWriting() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        weeklyThemeWritingCount += 1
        UserDefaults.standard.set(weeklyThemeWritingCount, forKey: themeWritingCountKey)
    }
    
    /// 获取剩余主题写诗次数
    func remainingThemeWriting() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeThemeWriting - weeklyThemeWritingCount)
    }
    
    // MARK: - Mimic Writing Limit
    
    /// 检查是否可以使用临摹写诗
    func canUseMimicWriting() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetWeeklyLimit()
        return weeklyMimicWritingCount < maxFreeMimicWriting
    }
    
    /// 使用一次临摹写诗
    func useMimicWriting() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        weeklyMimicWritingCount += 1
        UserDefaults.standard.set(weeklyMimicWritingCount, forKey: mimicWritingCountKey)
    }
    
    /// 获取剩余临摹写诗次数
    func remainingMimicWriting() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeMimicWriting - weeklyMimicWritingCount)
    }
    
    // MARK: - Premium Features
    
    /// 检查是否可以使用高级图片模板
    func canUseImageStyle(_ style: ImageStyle) -> Bool {
        !style.isPremium || isSubscribed
    }
    
    /// 检查是否可以使用 AI 生成模板
    func canUseAITemplates() -> Bool {
        isSubscribed
    }
    
    // MARK: - Computed Properties
    
    /// 到期时间格式化字符串
    var expirationDateString: String {
        guard let date = expirationDate else {
            // StoreKit Testing 模拟到期时间
            if isSubscribed, let subscription = currentSubscription {
                let mockExpiration = Calendar.current.date(
                    byAdding: subscription == .monthly ? .month : (subscription == .quarterly ? .month : .year),
                    value: subscription == .monthly ? 1 : (subscription == .quarterly ? 3 : 1),
                    to: Date()
                ) ?? Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                return formatter.string(from: mockExpiration)
            }
            return "长期有效"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    
    private func subscriptionTypeFromProductID(_ productID: String) -> SubscriptionType? {
        switch productID {
        case SubscriptionType.monthly.productID:
            return .monthly
        case SubscriptionType.quarterly.productID:
            return .quarterly
        case SubscriptionType.yearly.productID:
            return .yearly
        default:
            return nil
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case verificationFailed
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "订阅验证失败，请稍后重试"
        case .userCancelled:
            return "已取消购买"
        case .pending:
            return "购买待处理，请稍后确认"
        case .unknown:
            return "未知错误，请联系客服"
        }
    }
}

// MARK: - Image Style

enum ImageStyle: String, CaseIterable {
    case basic = "基础"
    case inkWash = "水墨"
    case floral = "花卉"
    case classical = "古典"
    case landscape = "山水"
    case modern = "现代"
    
    var isPremium: Bool {
        self != .basic
    }
}

