//
//  Poem.swift
//  山海诗馆
//
//  诗歌数据模型
//

import Foundation

/// 诗歌模型
struct Poem: Identifiable, Equatable {
    let id: String
    var title: String                  // 诗歌标题
    var content: String                // 诗歌内容
    var authorName: String             // 作者笔名
    var createdAt: Date                // 创建时间
    var updatedAt: Date                // 更新时间
    
    // 可选元数据
    var tags: [String]                 // 标签（如：风、雨、城市等）
    var writingMode: WritingMode       // 创作模式
    var referencePoem: String?         // 参考诗歌（模仿模式下使用）
    var aiComment: String?             // AI 点评
    
    // 社交数据
    var likeCount: Int                 // 点赞数
    var isLiked: Bool                  // 当前用户是否点赞
    var isFavorited: Bool              // 是否收藏
    var isPublished: Bool              // 是否发布（否则是草稿）
    
    // 初始化方法
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        authorName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        writingMode: WritingMode = .direct,
        referencePoem: String? = nil,
        aiComment: String? = nil,
        likeCount: Int = 0,
        isLiked: Bool = false,
        isFavorited: Bool = false,
        isPublished: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorName = authorName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.writingMode = writingMode
        self.referencePoem = referencePoem
        self.aiComment = aiComment
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isFavorited = isFavorited
        self.isPublished = isPublished
    }
    
    /// 字数统计
    var wordCount: Int {
        content.count
    }
    
    /// 行数统计
    var lineCount: Int {
        content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
    }
    
    /// 格式化的创建时间
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: createdAt)
    }
    
    /// 简短的时间显示（用于列表）
    var shortDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Codable

extension Poem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, content, authorName, createdAt, updatedAt
        case tags, writingMode, referencePoem, aiComment
        case likeCount, isLiked, isFavorited, isPublished
    }
}

// MARK: - 示例数据

extension Poem {
    /// 示例诗歌（用于预览和测试）
    static var example: Poem {
        Poem(
            title: "城市夜晚",
            content: """
            路灯一盏盏亮起
            像是在点名
            
            却没有人
            应答
            
            夜色深了
            我还在路上
            """,
            authorName: "行者",
            tags: ["城市", "夜晚", "孤独"],
            writingMode: .direct,
            likeCount: 23,
            isPublished: true
        )
    }
    
    /// 多个示例诗歌
    static var examples: [Poem] {
        [
            Poem(
                title: "城市夜晚",
                content: """
                路灯一盏盏亮起
                像是在点名
                
                却没有人
                应答
                
                夜色深了
                我还在路上
                """,
                authorName: "行者",
                tags: ["城市", "夜晚"],
                writingMode: .direct,
                likeCount: 23,
                isPublished: true
            ),
            Poem(
                title: "雨",
                content: """
                雨落在玻璃上
                流下来
                
                你说雨天很美
                
                现在
                雨还在下
                """,
                authorName: "诗人甲",
                tags: ["雨", "思念"],
                writingMode: .theme,
                likeCount: 45,
                isPublished: true
            ),
            Poem(
                title: "窗",
                content: """
                窗外的树
                比我自由
                
                它们摇晃
                我静止
                
                但我有
                它们没有的
                窗
                """,
                authorName: "云游",
                tags: ["窗", "自由"],
                writingMode: .direct,
                likeCount: 67,
                isPublished: true
            ),
            Poem(
                title: "等待",
                content: """
                咖啡凉了
                对面的椅子
                还是空的
                
                我又续了一杯
                继续等
                """,
                authorName: "行者",
                tags: ["等待", "孤独"],
                writingMode: .theme,
                likeCount: 34,
                isPublished: true
            ),
            Poem(
                title: "海",
                content: """
                海浪一遍遍
                冲刷着沙滩上的脚印
                
                像是在
                擦拭记忆
                
                但总有些痕迹
                深深的
                洗不掉
                """,
                authorName: "诗人甲",
                tags: ["海", "记忆"],
                writingMode: .direct,
                likeCount: 89,
                isPublished: true
            )
        ]
    }
}

