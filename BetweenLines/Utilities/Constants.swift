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

// MARK: - 设计系统：颜色（基于 Lovart 设计规范）

enum Colors {
    // 主背景：纯白
    static let backgroundCream = Color.white            // #FFFFFF
    
    // 文字：墨色美学系统
    static let textInk = Color(hex: "0A0A0A")           // 主文本：深邃墨黑
    static let textSecondary = Color(hex: "4A4A4A")     // 次级文本：中灰
    static let textTertiary = Color(hex: "ABABAB")      // 辅助文本：浅灰
    static let textQuaternary = Color(hex: "D4D4D4")    // 四级文字：极浅灰
    
    // 强调色：纯黑系统
    static let accentTeal = Color(hex: "1A1A1A")        // 强调色：纯黑
    static let accentSecondary = Color(hex: "4A4A4A")   // 次强调色：中灰
    
    // 边框和分割
    static let white = Color.white
    static let divider = Color(hex: "E5E5E5")           // 分割线/图标描边
    static let border = Color(hex: "E5E5E5")            // 边框：1pt
    static let cardBackground = Color(hex: "FBFBFB")    // 卡片背景：几乎白色
    
    // 状态色
    static let error = Color(hex: "D32F2F")
    static let success = Color(hex: "388E3C")
}

// MARK: - 设计系统：字体（基于 Lovart 设计规范）

enum Fonts {
    // 一级标题：宋体/衬线，极细，72-96pt
    static func h1() -> Font { .system(size: 84, weight: .ultraLight, design: .serif) }
    static func h1Large() -> Font { .system(size: 96, weight: .ultraLight, design: .serif) }
    static func h1Small() -> Font { .system(size: 72, weight: .ultraLight, design: .serif) }
    
    // 二级标题：宋体/衬线，极细，48-64pt
    static func h2() -> Font { .system(size: 56, weight: .ultraLight, design: .serif) }
    static func h2Large() -> Font { .system(size: 64, weight: .ultraLight, design: .serif) }
    static func h2Small() -> Font { .system(size: 48, weight: .ultraLight, design: .serif) }
    
    // 诗歌内容：宋体，Light，20-24pt（适合诗歌阅读）
    static func bodyPoem() -> Font { .system(size: 22, weight: .light, design: .serif) }
    static func bodyPoemLarge() -> Font { .system(size: 24, weight: .light, design: .serif) }
    
    // 正文：宋体，Light，16-20pt
    static func body() -> Font { .system(size: 18, weight: .light, design: .serif) }
    static func bodyLarge() -> Font { .system(size: 20, weight: .light, design: .serif) }
    static func bodySmall() -> Font { .system(size: 16, weight: .light, design: .serif) }
    
    // 辅助文字：无衬线，极轻，12-14pt
    static func caption() -> Font { .system(size: 13, weight: .ultraLight, design: .default) }
    static func captionLarge() -> Font { .system(size: 14, weight: .ultraLight, design: .default) }
    static func captionSmall() -> Font { .system(size: 12, weight: .ultraLight, design: .default) }
    
    // 兼容旧代码的别名
    static func displayLarge() -> Font { h1() }
    static func displayMedium() -> Font { h2() }
    static func titleLarge() -> Font { h2() }
    static func titleMedium() -> Font { h2Small() }
    static func titleSmall() -> Font { bodyLarge() }
    static func bodyRegular() -> Font { body() }
    static func bodyLight() -> Font { bodySmall() }
    static func footnote() -> Font { captionSmall() }
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

// MARK: - 设计系统：圆角（基于 Lovart 设计规范）

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 6
    static let large: CGFloat = 8
    static let card: CGFloat = 4         // 卡片圆角：4-8pt
}

// MARK: - 设计系统：UI组件规范（基于 Lovart 设计规范）

enum ComponentSize {
    // 按钮：高度48pt，左右内边距32pt
    static let buttonHeight: CGFloat = 48
    static let buttonPaddingHorizontal: CGFloat = 32
    static let buttonBorderWidth: CGFloat = 1
    
    // 输入框：高度40-48pt，下划线风格，1pt边框
    static let inputHeight: CGFloat = 48
    static let inputHeightMin: CGFloat = 40
    static let inputBorderWidth: CGFloat = 1
    
    // 卡片：内边距32-40pt，微边框1pt
    static let cardPadding: CGFloat = 36
    static let cardPaddingMin: CGFloat = 32
    static let cardPaddingMax: CGFloat = 40
    static let cardBorderWidth: CGFloat = 1
    
    // 图标：线性风格，1px描边，尺寸24×24px或32×32px
    static let iconSmall: CGFloat = 24
    static let iconLarge: CGFloat = 32
    static let iconStrokeWidth: CGFloat = 1
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
    static let poemsStorageKey = "saved_poems"
    static let openAIAPIKey = "openAI_API_Key"
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

