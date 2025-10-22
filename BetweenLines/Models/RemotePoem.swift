//
//  RemotePoem.swift
//  山海诗馆
//
//  远程诗歌数据模型（对应 Supabase poems 表）
//

import Foundation

/// 远程诗歌模型（从 Supabase 获取的数据）
struct RemotePoem: Codable, Identifiable {
    
    // MARK: - 基本信息
    
    let id: UUID
    var title: String
    var content: String
    let authorId: UUID
    
    // MARK: - 时间戳
    
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - 创作信息
    
    var writingMode: String?
    var tags: [String]
    var aiComment: String?
    
    // MARK: - 状态
    
    var isPublished: Bool
    var isDraft: Bool
    
    // MARK: - 统计
    
    var likeCount: Int
    var viewCount: Int
    
    // MARK: - 作者信息（从 JOIN 获取）
    
    var authorUsername: String?
    var authorDisplayName: String?
    var authorPoetTitle: String?
    
    // MARK: - 用户状态（从当前用户视角）
    
    var isLikedByMe: Bool?
    var isFavoritedByMe: Bool?
    
    // MARK: - CodingKeys（映射 snake_case）
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case authorId = "author_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case writingMode = "writing_mode"
        case tags
        case aiComment = "ai_comment"
        case isPublished = "is_published"
        case isDraft = "is_draft"
        case likeCount = "like_count"
        case viewCount = "view_count"
        case authorUsername = "author_username"
        case authorDisplayName = "author_display_name"
        case authorPoetTitle = "author_poet_title"
        case isLikedByMe = "is_liked_by_me"
        case isFavoritedByMe = "is_favorited_by_me"
    }
}

// MARK: - 转换为本地 Poem 模型

extension RemotePoem {
    
    /// 转换为本地 Poem 模型
    /// 用于在前端显示（兼容现有代码）
    func toLocalPoem() -> Poem {
        Poem(
            id: id.uuidString,
            title: title,
            content: content,
            authorName: authorUsername ?? authorDisplayName ?? "匿名诗人",
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags,
            writingMode: writingMode,
            referencePoem: nil,
            aiComment: aiComment,
            inMyCollection: false,  // 需要单独查询
            inSquare: isPublished,
            squareId: isPublished ? id.uuidString : nil,
            squarePublishedAt: isPublished ? createdAt : nil,
            squareLikeCount: likeCount,
            likeCount: likeCount,
            isLiked: isLikedByMe ?? false,
            isPublished: isPublished
        )
    }
}

// MARK: - 从本地 Poem 创建（用于上传）

extension RemotePoem {
    
    /// 从本地 Poem 创建 RemotePoem（用于上传到 Supabase）
    /// - Parameters:
    ///   - poem: 本地诗歌
    ///   - authorId: 作者 ID
    static func from(localPoem poem: Poem, authorId: UUID) -> RemotePoem {
        RemotePoem(
            id: UUID(uuidString: poem.id) ?? UUID(),
            title: poem.title,
            content: poem.content,
            authorId: authorId,
            createdAt: poem.createdAt,
            updatedAt: poem.updatedAt,
            writingMode: poem.writingMode,
            tags: poem.tags,
            aiComment: poem.aiComment,
            isPublished: poem.inSquare,
            isDraft: !poem.inSquare,
            likeCount: poem.squareLikeCount,
            viewCount: 0,
            authorUsername: nil,
            authorDisplayName: nil,
            authorPoetTitle: nil,
            isLikedByMe: nil,
            isFavoritedByMe: nil
        )
    }
}

// MARK: - 创建请求参数

extension RemotePoem {
    
    /// 用于插入数据库的字典（不包含自动生成的字段）
    var insertDict: [String: AnyEncodable] {
        [
            "title": AnyEncodable(title),
            "content": AnyEncodable(content),
            "author_id": AnyEncodable(authorId.uuidString),
            "writing_mode": AnyEncodable(writingMode),
            "tags": AnyEncodable(tags),
            "ai_comment": AnyEncodable(aiComment),
            "is_published": AnyEncodable(isPublished),
            "is_draft": AnyEncodable(isDraft)
        ]
    }
    
    /// 用于更新数据库的字典
    var updateDict: [String: AnyEncodable] {
        [
            "title": AnyEncodable(title),
            "content": AnyEncodable(content),
            "writing_mode": AnyEncodable(writingMode),
            "tags": AnyEncodable(tags),
            "ai_comment": AnyEncodable(aiComment),
            "is_published": AnyEncodable(isPublished),
            "is_draft": AnyEncodable(isDraft),
            "updated_at": AnyEncodable(ISO8601DateFormatter().string(from: Date()))
        ]
    }
}

// MARK: - AnyEncodable（辅助类型）

/// 类型擦除的 Encodable，用于创建字典
struct AnyEncodable: Encodable {
    let value: Encodable
    
    init(_ value: Encodable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

