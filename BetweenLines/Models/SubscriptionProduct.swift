//
//  SubscriptionProduct.swift
//  山海诗馆
//
//  订阅产品定义
//

import Foundation
import StoreKit

/// 订阅产品类型
enum SubscriptionType: String, Codable {
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .monthly: return "月卡"
        case .quarterly: return "季卡"
        case .yearly: return "年卡"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "¥9.9"
        case .quarterly: return "¥19.9"
        case .yearly: return "¥69.9"
        }
    }
    
    var productID: String {
        switch self {
        case .monthly: return "com.shanhai.poetry.monthly"
        case .quarterly: return "com.shanhai.poetry.quarterly"
        case .yearly: return "com.shanhai.poetry.yearly"
        }
    }
    
    var description: String {
        switch self {
        case .monthly: return "每月自动续费"
        case .quarterly: return "每 3 个月自动续费，省 33%"
        case .yearly: return "每年自动续费，省 41%"
        }
    }
    
    var badge: String? {
        switch self {
        case .monthly: return nil
        case .quarterly: return "推荐"
        case .yearly: return "最划算"
        }
    }
}

/// 会员权益
enum MemberBenefit: String, CaseIterable {
    case unlimitedAI = "AI 点评无限次"
    case aiInspiration = "AI 续写思路"
    case aiTemplates = "AI 生成写诗模板"
    case aiThemes = "AI 推荐每日主题"
    case imageStyles = "多种图片模板"
    case noAds = "无广告体验"
    case exclusiveBadge = "会员专属标识"
    
    var icon: String {
        switch self {
        case .unlimitedAI: return "sparkles"
        case .aiInspiration: return "lightbulb.fill"
        case .aiTemplates: return "doc.text.image"
        case .aiThemes: return "lightbulb"
        case .imageStyles: return "photo.stack"
        case .noAds: return "eye.slash"
        case .exclusiveBadge: return "crown"
        }
    }
}

