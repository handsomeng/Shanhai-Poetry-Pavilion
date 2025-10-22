//
//  PoetTitle.swift
//  山海诗馆
//
//  诗人称号系统
//

import Foundation

/// 诗人称号
enum PoetTitle: String, CaseIterable, Codable {
    case beginner = "初见诗人"      // 1-5首
    case seeker = "寻山诗人"        // 6-10首
    case listener = "听雨诗人"      // 11-20首
    case wanderer = "寻梅诗人"      // 21-50首
    case gazer = "望月诗人"         // 51-100首
    case climber = "登高诗人"       // 101-200首
    case master = "山河诗人"        // 201-500首
    case immortal = "谪仙诗人"      // 500+首
    
    /// 显示名称
    var displayName: String {
        self.rawValue
    }
    
    /// 称号图标
    var icon: String {
        switch self {
        case .beginner: return "🌊"
        case .seeker: return "⛰️"
        case .listener: return "☁️"
        case .wanderer: return "❄️"
        case .gazer: return "🌙"
        case .climber: return "🏔️"
        case .master: return "🗺️"
        case .immortal: return "✨"
        }
    }
    
    /// 称号描述
    var description: String {
        switch self {
        case .beginner: return "初入山海，诗心萌动"
        case .seeker: return "开始探索诗歌山河"
        case .listener: return "观云听雨，诗意渐浓"
        case .wanderer: return "踏雪寻梅，坚持不懈"
        case .gazer: return "望月怀远，境界渐高"
        case .climber: return "登高望远，视野开阔"
        case .master: return "经纬山河，笔力千钧"
        case .immortal: return "诗仙之境，山海之间"
        }
    }
    
    /// 解锁所需诗歌数量
    var requiredCount: Int {
        switch self {
        case .beginner: return 1
        case .seeker: return 6
        case .listener: return 11
        case .wanderer: return 21
        case .gazer: return 51
        case .climber: return 101
        case .master: return 201
        case .immortal: return 500
        }
    }
    
    /// 下一个称号所需诗歌数量（如果是最高级则返回nil）
    var nextTitleRequiredCount: Int? {
        guard let currentIndex = PoetTitle.allCases.firstIndex(of: self),
              currentIndex < PoetTitle.allCases.count - 1 else {
            return nil
        }
        return PoetTitle.allCases[currentIndex + 1].requiredCount
    }
    
    /// 根据诗歌数量获取对应称号
    static func title(forPoemCount count: Int) -> PoetTitle {
        // 从后往前找，找到第一个满足条件的称号
        for title in PoetTitle.allCases.reversed() {
            if count >= title.requiredCount {
                return title
            }
        }
        return .beginner
    }
    
    /// 是否是最高称号
    var isMaxTitle: Bool {
        self == .immortal
    }
    
    /// 进度百分比（到下一个称号）
    func progress(currentCount: Int) -> Double {
        guard let nextRequired = nextTitleRequiredCount else {
            return 1.0  // 已经是最高称号
        }
        
        let currentRequired = requiredCount
        let range = Double(nextRequired - currentRequired)
        let current = Double(max(0, currentCount - currentRequired))
        
        return min(1.0, current / range)
    }
    
    /// 距离下一称号还需多少首
    func poemsToNextTitle(currentCount: Int) -> Int? {
        guard let nextRequired = nextTitleRequiredCount else {
            return nil  // 已经是最高称号
        }
        return max(0, nextRequired - currentCount)
    }
}

// MARK: - Title Achievement Info

/// 称号成就信息（用于展示）
struct TitleAchievement {
    let title: PoetTitle
    let isUnlocked: Bool
    let currentCount: Int
    
    var displayText: String {
        if isUnlocked {
            return "已解锁"
        } else {
            let required = title.requiredCount
            return "需 \(required) 首"
        }
    }
}

