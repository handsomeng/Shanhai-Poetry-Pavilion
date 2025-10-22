//
//  InteractionModels.swift
//  山海诗馆
//
//  互动相关数据模型（点赞、收藏、评论）
//

import Foundation

// MARK: - 点赞

/// 点赞记录
struct Like: Codable, Identifiable {
    let id: String
    let userId: String
    let poemId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case poemId = "poem_id"
        case createdAt = "created_at"
    }
}

/// 创建点赞请求
struct CreateLikeRequest: Codable {
    let userId: String
    let poemId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case poemId = "poem_id"
    }
}

// MARK: - 收藏

/// 收藏记录
struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String
    let poemId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case poemId = "poem_id"
        case createdAt = "created_at"
    }
}

/// 创建收藏请求
struct CreateFavoriteRequest: Codable {
    let userId: String
    let poemId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case poemId = "poem_id"
    }
}

// MARK: - 评论

/// 评论
struct Comment: Codable, Identifiable {
    let id: String
    let userId: String
    let poemId: String
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case poemId = "poem_id"
        case content
        case createdAt = "created_at"
    }
}

/// 创建评论请求
struct CreateCommentRequest: Codable {
    let userId: String
    let poemId: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case poemId = "poem_id"
        case content
    }
}

