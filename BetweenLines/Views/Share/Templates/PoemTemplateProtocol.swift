//
//  PoemTemplateProtocol.swift
//  山海诗馆
//
//  诗歌图片模板协议
//

import SwiftUI

/// 诗歌模板协议
protocol PoemTemplate {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    
    /// 渲染模板视图
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View
}

/// 模板类型枚举
enum PoemTemplateType: String, CaseIterable, Identifiable {
    case lovartMinimal = "Lovart 极简"
    case mountainSea = "山海国风"
    case warmJapanese = "暖系日系"
    case darkNight = "深夜暗黑"
    case cyberpunk = "赛博朋克"
    case handwritten = "手写笔记"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .lovartMinimal: return "🤍"
        case .mountainSea: return "🎨"
        case .warmJapanese: return "🌸"
        case .darkNight: return "🌙"
        case .cyberpunk: return "🌃"
        case .handwritten: return "✍️"
        }
    }
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View {
        switch self {
        case .lovartMinimal:
            LovartMinimalTemplate().render(poem: poem, size: size)
        case .mountainSea:
            MountainSeaTemplate().render(poem: poem, size: size)
        case .warmJapanese:
            WarmJapaneseTemplate().render(poem: poem, size: size)
        case .darkNight:
            DarkNightTemplate().render(poem: poem, size: size)
        case .cyberpunk:
            CyberpunkTemplate().render(poem: poem, size: size)
        case .handwritten:
            HandwrittenTemplate().render(poem: poem, size: size)
        }
    }
}

