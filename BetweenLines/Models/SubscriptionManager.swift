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
    
    // AI 点评限额（免费用户）
    @Published private(set) var dailyAICommentCount: Int = 0
    private let maxFreeAIComments = 3
    
    // AI 续写灵感限额（免费用户）
    @Published private(set) var dailyInspirationCount: Int = 0
    private let maxFreeInspirations = 2
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - UserDefaults Keys
    
    private let lastResetDateKey = "lastAICommentResetDate"
    private let aiCommentCountKey = "dailyAICommentCount"
    private let inspirationCountKey = "dailyInspirationCount"
    private let subscriptionTypeKey = "subscriptionType"
    
    // MARK: - Initialization
    
    private init() {
        // 启动时检查订阅状态
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
            checkAndResetDailyLimit()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = [
                SubscriptionType.monthly.productID,
                SubscriptionType.quarterly.productID,
                SubscriptionType.yearly.productID
            ]
            
            products = try await Product.products(for: productIDs)
                .sorted { product1, product2 in
                    // 按价格排序：月卡 < 季卡 < 年卡
                    product1.price < product2.price
                }
        } catch {
            print("Failed to load products: \(error)")
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
        
        checkAndResetDailyLimit()
        return dailyAICommentCount < maxFreeAIComments
    }
    
    /// 使用一次 AI 点评
    func useAIComment() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        dailyAICommentCount += 1
        UserDefaults.standard.set(dailyAICommentCount, forKey: aiCommentCountKey)
    }
    
    /// 获取剩余 AI 点评次数
    func remainingAIComments() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeAIComments - dailyAICommentCount)
    }
    
    /// 检查并重置每日限额
    private func checkAndResetDailyLimit() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastReset = Calendar.current.startOfDay(for: lastResetDate)
            
            if lastReset < today {
                // 新的一天，重置计数
                dailyAICommentCount = 0
                dailyInspirationCount = 0
                UserDefaults.standard.set(0, forKey: aiCommentCountKey)
                UserDefaults.standard.set(0, forKey: inspirationCountKey)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            } else {
                // 同一天，读取计数
                dailyAICommentCount = UserDefaults.standard.integer(forKey: aiCommentCountKey)
                dailyInspirationCount = UserDefaults.standard.integer(forKey: inspirationCountKey)
            }
        } else {
            // 首次运行
            dailyAICommentCount = 0
            dailyInspirationCount = 0
            UserDefaults.standard.set(0, forKey: aiCommentCountKey)
            UserDefaults.standard.set(0, forKey: inspirationCountKey)
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }
    
    // MARK: - AI Inspiration Limit
    
    /// 检查是否可以使用 AI 续写灵感
    func canUseInspiration() -> Bool {
        if isSubscribed {
            return true  // 会员无限次
        }
        
        checkAndResetDailyLimit()
        return dailyInspirationCount < maxFreeInspirations
    }
    
    /// 使用一次 AI 续写灵感
    func useInspiration() {
        if isSubscribed {
            return  // 会员不计数
        }
        
        dailyInspirationCount += 1
        UserDefaults.standard.set(dailyInspirationCount, forKey: inspirationCountKey)
    }
    
    /// 获取剩余 AI 续写灵感次数
    func remainingInspirations() -> Int {
        if isSubscribed {
            return -1  // -1 表示无限
        }
        return max(0, maxFreeInspirations - dailyInspirationCount)
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

