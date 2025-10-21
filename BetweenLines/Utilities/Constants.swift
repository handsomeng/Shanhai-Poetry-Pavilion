//
//  Constants.swift
//  BetweenLines - 字里行间
//
//  全局常量定义：颜色、字体、间距、配置等
//

import SwiftUI

// MARK: - 应用常量

enum AppConstants {
    static let appName = "山海诗馆"
    static let appNameEN = "ShanHaiPoetry"
    static let version = "1.0.0"
    static let cloudKitContainerID = "iCloud.com.yourcompany.BetweenLines"
    
    // OpenAI 配置
    static let openAIAPIKey = "sk-5f25856393a34aabaea722efa1d3531d"
    static let openAIModel = "gpt-4o-mini"
    static let openAIMaxTokens = 800
    static let openAITimeout: TimeInterval = 15.0
    static let openAIMaxRetries = 3
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
}

// MARK: - 设计系统：颜色（极简白色调）

enum Colors {
    // 主背景：纯白
    static let backgroundCream = Color.white
    
    // 文字：极简黑白灰
    static let textInk = Color(hex: "1A1A1A")           // 主文字：几乎纯黑
    static let textSecondary = Color(hex: "8E8E8E")     // 次要文字：优雅灰
    static let textTertiary = Color(hex: "C7C7C7")      // 三级文字：浅灰
    
    // 强调色：克制的深灰蓝
    static let accentTeal = Color(hex: "2C3E50")        // 深灰蓝，优雅内敛
    
    // 辅助色
    static let white = Color.white
    static let divider = Color(hex: "F0F0F0")           // 极浅分割线
    static let cardBackground = Color(hex: "FAFAFA")    // 卡片背景：极浅灰
    static let error = Color(hex: "D32F2F")
    static let success = Color(hex: "388E3C")
}

// MARK: - 设计系统：字体（优雅宋体+增大字号）

enum Fonts {
    // 标题：宋体，细腻优雅
    static func titleLarge() -> Font { .system(size: 32, weight: .light, design: .serif) }
    static func titleMedium() -> Font { .system(size: 24, weight: .light, design: .serif) }
    static func titleSmall() -> Font { .system(size: 20, weight: .light, design: .serif) }
    
    // 诗歌内容：宋体，大字号，增加行距
    static func bodyPoem() -> Font { .system(size: 20, weight: .light, design: .serif) }
    
    // 正文：简洁无衬线
    static func bodyRegular() -> Font { .system(size: 16, weight: .regular, design: .default) }
    static func bodyLight() -> Font { .system(size: 16, weight: .light, design: .default) }
    
    // 辅助文字：更小更轻
    static func caption() -> Font { .system(size: 13, weight: .light) }
    static func footnote() -> Font { .system(size: 11, weight: .light) }
    static func monospace() -> Font { .system(size: 14, weight: .light, design: .monospaced) }
}

// MARK: - 设计系统：间距（大幅增加留白）

enum Spacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 32
    static let xl: CGFloat = 48
    static let xxl: CGFloat = 64
    static let xxxl: CGFloat = 96     // 超大留白
}

// MARK: - 设计系统：圆角（极简化，减小圆角）

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 6
    static let large: CGFloat = 8
    static let card: CGFloat = 0         // 卡片使用直角，更现代
}

// MARK: - 业务常量

enum WritingMode: String, CaseIterable, Identifiable {
    case direct = "direct", mimic = "mimic", theme = "theme"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .direct: return "直接写诗"
        case .mimic: return "模仿写诗"
        case .theme: return "主题写诗"
        }
    }
}

enum ThemeKeyword: String, CaseIterable, Identifiable {
    case wind = "风", rain = "雨", window = "窗", dream = "梦"
    case city = "城市", loneliness = "孤独", love = "爱", time = "时间"
    case sea = "海", night = "夜"
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum ContentLimits {
    static let penNameMin = 2, penNameMax = 20
    static let taglineMax = 50
    static let poemContentMin = 10, poemContentMax = 5000
    static let commentMin = 20, commentMax = 200
}

enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let penName = "penName"
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

