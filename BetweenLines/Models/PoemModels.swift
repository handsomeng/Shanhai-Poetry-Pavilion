//
//  PoemModels.swift
//  山海诗馆
//
//  诗歌相关数据模型
//

import Foundation

// MARK: - 远程诗歌（来自后端）

/// 远程诗歌（poems 表）
struct RemotePoem: Codable, Identifiable {
    let id: String
    let authorId: String
    let title: String
    let content: String
    let style: String
    let isPublished: Bool  // 修改：匹配数据库字段 is_published
    var isDraft: Bool      // 新增：匹配数据库字段 is_draft
    var tags: [String]?
    var likeCount: Int
    var commentCount: Int
    var createdAt: String
    var updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case title
        case content
        case style
        case isPublished = "is_published"  // 修改：从 is_public 改为 is_published
        case isDraft = "is_draft"          // 新增
        case tags
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// 广场诗歌（square_poems 视图）
struct SquarePoem: Codable, Identifiable {
    let id: String
    let authorId: String
    let authorUsername: String
    let authorPoetTitle: String
    let title: String
    let content: String
    let style: String
    var tags: [String]?
    var likeCount: Int
    var commentCount: Int
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case authorUsername = "author_username"
        case authorPoetTitle = "author_poet_title"
        case title
        case content
        case style
        case tags
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case createdAt = "created_at"
    }
}

// MARK: - 诗歌请求

/// 创建诗歌请求
struct CreatePoemRequest: Codable {
    let authorId: String
    let title: String
    let content: String
    let style: String
    let isPublished: Bool  // 修改：匹配数据库字段 is_published
    let isDraft: Bool      // 新增：匹配数据库字段 is_draft
    var tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case authorId = "author_id"
        case title
        case content
        case style
        case isPublished = "is_published"  // 修改：从 is_public 改为 is_published
        case isDraft = "is_draft"          // 新增
        case tags
    }
}

/// 更新诗歌请求
struct UpdatePoemRequest: Codable {
    var title: String?
    var content: String?
    var style: String?
    var isPublished: Bool?  // 修改：匹配数据库字段 is_published
    var isDraft: Bool?      // 新增：匹配数据库字段 is_draft
    var tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case style
        case isPublished = "is_published"  // 修改：从 is_public 改为 is_published
        case isDraft = "is_draft"          // 新增
        case tags
    }
}

