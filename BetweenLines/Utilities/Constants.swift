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

// MARK: - 设计系统：颜色（Dribbble 高级极简风格）

enum Colors {
    // 主背景：纯白
    static let backgroundCream = Color.white
    
    // 文字：精致黑白灰系统
    static let textInk = Color(hex: "0A0A0A")           // 主文字：深邃黑
    static let textSecondary = Color(hex: "6B6B6B")     // 次要文字：中性灰
    static let textTertiary = Color(hex: "ABABAB")      // 三级文字：浅灰
    static let textQuaternary = Color(hex: "D4D4D4")    // 四级文字：极浅灰
    
    // 强调色：优雅的深色系统
    static let accentTeal = Color(hex: "1A1A1A")        // 纯黑强调，极简
    static let accentSecondary = Color(hex: "4A4A4A")   // 灰色强调
    
    // 边框和分割
    static let white = Color.white
    static let divider = Color(hex: "EFEFEF")           // 几乎不可见的分割线
    static let border = Color(hex: "E8E8E8")            // 精致边框
    static let cardBackground = Color(hex: "FBFBFB")    // 卡片背景：几乎白色
    
    // 状态色
    static let error = Color(hex: "D32F2F")
    static let success = Color(hex: "388E3C")
}

// MARK: - 设计系统：字体（Dribbble 极简风格）

enum Fonts {
    // 超大标题：震撼视觉
    static func displayLarge() -> Font { .system(size: 48, weight: .thin, design: .serif) }
    static func displayMedium() -> Font { .system(size: 36, weight: .ultraLight, design: .serif) }
    
    // 标题：极细优雅
    static func titleLarge() -> Font { .system(size: 28, weight: .ultraLight, design: .serif) }
    static func titleMedium() -> Font { .system(size: 22, weight: .thin, design: .serif) }
    static func titleSmall() -> Font { .system(size: 18, weight: .light, design: .serif) }
    
    // 诗歌内容：宋体，超大字号
    static func bodyPoem() -> Font { .system(size: 24, weight: .ultraLight, design: .serif) }
    
    // 正文：极细无衬线
    static func bodyRegular() -> Font { .system(size: 15, weight: .light, design: .default) }
    static func bodyLight() -> Font { .system(size: 15, weight: .ultraLight, design: .default) }
    
    // 辅助文字：几乎透明的轻盈
    static func caption() -> Font { .system(size: 12, weight: .ultraLight) }
    static func footnote() -> Font { .system(size: 10, weight: .ultraLight) }
    static func monospace() -> Font { .system(size: 13, weight: .ultraLight, design: .monospaced) }
}

// MARK: - 设计系统：间距（Dribbble 级别留白）

enum Spacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 16
    static let md: CGFloat = 24
    static let lg: CGFloat = 40        // 加大
    static let xl: CGFloat = 64        // 加大
    static let xxl: CGFloat = 96       // 加大
    static let xxxl: CGFloat = 128     // 超大留白
    static let huge: CGFloat = 160     // 巨大留白
}

// MARK: - 设计系统：圆角（极简化，减小圆角）

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 6
    static let large: CGFloat = 8
    static let card: CGFloat = 0         // 卡片使用直角，更现代
}

// MARK: - 业务常量

enum WritingMode: String, CaseIterable, Identifiable, Codable {
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

