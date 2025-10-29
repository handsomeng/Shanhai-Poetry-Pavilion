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
    var userId: String?                // 所属用户ID（用于数据隔离）
    var createdAt: Date                // 创建时间
    var updatedAt: Date                // 更新时间
    
    // 可选元数据
    var tags: [String]                 // 标签（如：风、雨、城市等）
    var writingMode: WritingMode       // 创作模式
    var referencePoem: String?         // 参考诗歌（模仿模式下使用）
    var aiComment: String?             // AI 点评
    
    // 存储位置（新逻辑）
    var inMyCollection: Bool           // 是否在【我的诗集】
    var inSquare: Bool                 // 是否在【广场】
    var squareId: String?              // 广场上的ID（如果发布过）
    var squarePublishedAt: Date?       // 发布到广场的时间
    var squareLikeCount: Int           // 广场上的点赞数
    
    // 社交数据
    var likeCount: Int                 // 本地点赞数（废弃，改用 squareLikeCount）
    var isLiked: Bool                  // 当前用户是否点赞
    var isPublished: Bool              // 是否发布（废弃，改用 inSquare）
    
    // 审核和更新状态（新增）
    var auditStatus: AuditStatus       // 审核状态
    var hasUnpublishedChanges: Bool    // 是否有未发布到广场的本地修改
    var rejectionReason: String?       // 审核驳回原因
    
    // 初始化方法
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        authorName: String,
        userId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        writingMode: WritingMode = .direct,
        referencePoem: String? = nil,
        aiComment: String? = nil,
        inMyCollection: Bool = false,
        inSquare: Bool = false,
        squareId: String? = nil,
        squarePublishedAt: Date? = nil,
        squareLikeCount: Int = 0,
        likeCount: Int = 0,
        isLiked: Bool = false,
        isPublished: Bool = false,
        auditStatus: AuditStatus = .notPublished,
        hasUnpublishedChanges: Bool = false,
        rejectionReason: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorName = authorName
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.writingMode = writingMode
        self.referencePoem = referencePoem
        self.aiComment = aiComment
        self.inMyCollection = inMyCollection
        self.inSquare = inSquare
        self.squareId = squareId
        self.squarePublishedAt = squarePublishedAt
        self.squareLikeCount = squareLikeCount
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isPublished = isPublished
        self.auditStatus = auditStatus
        self.hasUnpublishedChanges = hasUnpublishedChanges
        self.rejectionReason = rejectionReason
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
    
    /// 带书名号的标题（用于显示）
    var displayTitle: String {
        if title.isEmpty {
            return "《无题》"
        } else {
            // 如果标题已经包含《》，不重复添加
            if title.hasPrefix("《") && title.hasSuffix("》") {
                return title
            } else {
                return "《\(title)》"
            }
        }
    }
}

// MARK: - Codable

extension Poem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, content, authorName, userId, createdAt, updatedAt
        case tags, writingMode, referencePoem, aiComment
        case inMyCollection, inSquare, squareId, squarePublishedAt, squareLikeCount
        case likeCount, isLiked, isPublished
        case auditStatus, hasUnpublishedChanges, rejectionReason
    }
}

// MARK: - 审核状态

/// 诗歌审核状态
enum AuditStatus: String, Codable {
    case notPublished    // 未发布
    case published       // 已发布（审核通过）
    case pending         // 审核中
    case rejected        // 审核驳回
    
    /// 状态描述
    var description: String {
        switch self {
        case .notPublished:
            return "未发布"
        case .published:
            return "已发布"
        case .pending:
            return "审核中"
        case .rejected:
            return "审核未通过"
        }
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
            inSquare: true,
            squareId: UUID().uuidString,
            squarePublishedAt: Date(),
            squareLikeCount: 23,
            isPublished: true
        )
    }
    
    /// 多个示例诗歌
    static var examples: [Poem] {
        let now = Date()
        return [
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
                createdAt: now.addingTimeInterval(-86400 * 5),
                tags: ["城市", "夜晚"],
                writingMode: .direct,
                inSquare: true,
                squareId: UUID().uuidString,
                squarePublishedAt: now.addingTimeInterval(-86400 * 5),
                squareLikeCount: 23,
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
                createdAt: now.addingTimeInterval(-86400 * 4),
                tags: ["雨", "思念"],
                writingMode: .theme,
                inSquare: true,
                squareId: UUID().uuidString,
                squarePublishedAt: now.addingTimeInterval(-86400 * 4),
                squareLikeCount: 45,
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
                createdAt: now.addingTimeInterval(-86400 * 3),
                tags: ["窗", "自由"],
                writingMode: .direct,
                inSquare: true,
                squareId: UUID().uuidString,
                squarePublishedAt: now.addingTimeInterval(-86400 * 3),
                squareLikeCount: 67,
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
                createdAt: now.addingTimeInterval(-86400 * 2),
                tags: ["等待", "孤独"],
                writingMode: .theme,
                inSquare: true,
                squareId: UUID().uuidString,
                squarePublishedAt: now.addingTimeInterval(-86400 * 2),
                squareLikeCount: 34,
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
                createdAt: now.addingTimeInterval(-86400 * 1),
                tags: ["海", "记忆"],
                writingMode: .direct,
                inSquare: true,
                squareId: UUID().uuidString,
                squarePublishedAt: now.addingTimeInterval(-86400 * 1),
                squareLikeCount: 89,
                isPublished: true
            )
        ]
    }
}

