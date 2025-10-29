//
//  PoemTemplateProtocol.swift
//  山海诗馆
//
//  诗歌图片模板协议
//

import SwiftUI

/// 诗歌模板协议
protocol PoemTemplateRenderable {
    associatedtype Content: View
    
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    
    /// 渲染模板视图
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> Content
}

/// 模板类型枚举
enum PoemTemplateType: String, CaseIterable, Identifiable {
    case lovartMinimal = "极简风格"
    case mountainSea = "山海国风"
    case warmJapanese = "暖系日系"
    case darkNight = "深夜暗黑"
    case cyberpunk = "赛博朋克"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .lovartMinimal: return "🤍"
        case .mountainSea: return "🎨"
        case .warmJapanese: return "🌸"
        case .darkNight: return "🌙"
        case .cyberpunk: return "🌃"
        }
    }
    
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> some View {
        switch self {
        case .lovartMinimal:
            LovartMinimalTemplate().render(poem: poem, poemIndex: poemIndex, size: size)
        case .mountainSea:
            MountainSeaTemplate().render(poem: poem, poemIndex: poemIndex, size: size)
        case .warmJapanese:
            WarmJapaneseTemplate().render(poem: poem, poemIndex: poemIndex, size: size)
        case .darkNight:
            DarkNightTemplate().render(poem: poem, poemIndex: poemIndex, size: size)
        case .cyberpunk:
            CyberpunkTemplate().render(poem: poem, poemIndex: poemIndex, size: size)
        }
    }
}

// MARK: - 统一底部信息组件

struct PoemBottomInfo: View {
    let poem: Poem
    let poemIndex: Int
    let textColor: Color
    let dividerColor: Color
    
    @StateObject private var poemManager = PoemManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // 分割线
            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)
            
            // 信息行（使用当前笔名，而非诗歌保存时的笔名）
            HStack(spacing: 0) {
                Text("山海诗馆")
                Text(" · ")
                Text(poemManager.currentUserName)
            }
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 第几首诗 + 日期
            HStack(spacing: 0) {
                Text("第 \(poemIndex) 首诗")
                Text(" · ")
                Text(poem.createdAt, format: .dateTime.year().month().day())
            }
            .font(.system(size: 11, weight: .light))
            .foregroundColor(textColor.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


