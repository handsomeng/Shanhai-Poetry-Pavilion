//
//  UserProfile.swift
//  山海诗馆
//
//  用户资料模型（对应 Supabase profiles 表）
//

import Foundation

/// 用户资料模型
struct UserProfile: Codable, Identifiable {
    
    // MARK: - 基本信息
    
    let id: UUID
    var username: String
    var displayName: String?
    var poetTitle: String
    
    // MARK: - 时间戳
    
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - 统计数据
    
    var totalPoems: Int
    var totalLikesReceived: Int
    
    // MARK: - 会员信息
    
    var isPremium: Bool
    var premiumExpiresAt: Date?
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case poetTitle = "poet_title"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case totalPoems = "total_poems"
        case totalLikesReceived = "total_likes_received"
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
    }
}

// MARK: - 计算属性

extension UserProfile {
    
    /// 显示名称（优先使用 displayName，否则使用 username）
    var effectiveDisplayName: String {
        displayName?.isEmpty == false ? displayName! : username
    }
    
    /// 是否为有效会员
    var isActivePremium: Bool {
        guard isPremium else { return false }
        guard let expiresAt = premiumExpiresAt else { return false }
        return expiresAt > Date()
    }
    
    /// 会员剩余天数
    var premiumDaysRemaining: Int? {
        guard let expiresAt = premiumExpiresAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day
        return max(0, days ?? 0)
    }
}

// MARK: - 创建/更新请求

extension UserProfile {
    
    /// 用于创建用户的字典
    static func createDict(userId: UUID, username: String, displayName: String? = nil) -> [String: AnyEncodable] {
        [
            "id": AnyEncodable(userId.uuidString),
            "username": AnyEncodable(username),
            "display_name": AnyEncodable(displayName),
            "poet_title": AnyEncodable("初见诗人")
        ]
    }
    
    /// 用于更新用户的字典
    var updateDict: [String: AnyEncodable] {
        [
            "username": AnyEncodable(username),
            "display_name": AnyEncodable(displayName),
            "updated_at": AnyEncodable(ISO8601DateFormatter().string(from: Date()))
        ]
    }
}

// MARK: - 示例数据

extension UserProfile {
    
    static let example = UserProfile(
        id: UUID(),
        username: "诗人小白",
        displayName: "小白",
        poetTitle: "寻山诗人",
        createdAt: Date(),
        updatedAt: Date(),
        totalPoems: 12,
        totalLikesReceived: 89,
        isPremium: true,
        premiumExpiresAt: Calendar.current.date(byAdding: .day, value: 30, to: Date())
    )
}

