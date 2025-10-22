//
//  InteractionService.swift
//  山海诗馆
//
//  互动服务 - 点赞、收藏、评论
//

import Foundation
import Combine

/// 互动服务
@MainActor
class InteractionService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 用户点赞的诗歌 ID 集合
    @Published var likedPoemIds: Set<String> = []
    
    /// 用户收藏的诗歌 ID 集合
    @Published var favoritedPoemIds: Set<String> = []
    
    // MARK: - 单例
    
    static let shared = InteractionService()
    
    private let client = SupabaseHTTPClient.shared
    
    private init() {}
    
    // MARK: - 点赞
    
    /// 检查是否已点赞
    func checkLiked(userId: String, poemId: String) async throws -> Bool {
        let likes: [Like] = try await client.request(
            method: .get,
            path: SupabaseConfig.likesTable,
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "poem_id", value: "eq.\(poemId)"),
                URLQueryItem(name: "select", value: "id")
            ]
        )
        
        let isLiked = !likes.isEmpty
        if isLiked {
            likedPoemIds.insert(poemId)
        }
        return isLiked
    }
    
    /// 点赞
    func like(userId: String, poemId: String) async throws {
        let request = CreateLikeRequest(userId: userId, poemId: poemId)
        
        let _: [Like] = try await client.request(
            method: .post,
            path: SupabaseConfig.likesTable,
            body: request
        )
        
        likedPoemIds.insert(poemId)
    }
    
    /// 取消点赞
    func unlike(userId: String, poemId: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await client.request(
            method: .delete,
            path: "\(SupabaseConfig.likesTable)?user_id=eq.\(userId)&poem_id=eq.\(poemId)"
        )
        
        likedPoemIds.remove(poemId)
    }
    
    /// 切换点赞状态
    func toggleLike(userId: String, poemId: String) async throws {
        if likedPoemIds.contains(poemId) {
            try await unlike(userId: userId, poemId: poemId)
        } else {
            try await like(userId: userId, poemId: poemId)
        }
    }
    
    // MARK: - 收藏
    
    /// 检查是否已收藏
    func checkFavorited(userId: String, poemId: String) async throws -> Bool {
        let favorites: [Favorite] = try await client.request(
            method: .get,
            path: SupabaseConfig.favoritesTable,
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "poem_id", value: "eq.\(poemId)"),
                URLQueryItem(name: "select", value: "id")
            ]
        )
        
        let isFavorited = !favorites.isEmpty
        if isFavorited {
            favoritedPoemIds.insert(poemId)
        }
        return isFavorited
    }
    
    /// 收藏
    func favorite(userId: String, poemId: String) async throws {
        let request = CreateFavoriteRequest(userId: userId, poemId: poemId)
        
        let _: [Favorite] = try await client.request(
            method: .post,
            path: SupabaseConfig.favoritesTable,
            body: request
        )
        
        favoritedPoemIds.insert(poemId)
    }
    
    /// 取消收藏
    func unfavorite(userId: String, poemId: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await client.request(
            method: .delete,
            path: "\(SupabaseConfig.favoritesTable)?user_id=eq.\(userId)&poem_id=eq.\(poemId)"
        )
        
        favoritedPoemIds.remove(poemId)
    }
    
    /// 切换收藏状态
    func toggleFavorite(userId: String, poemId: String) async throws {
        if favoritedPoemIds.contains(poemId) {
            try await unfavorite(userId: userId, poemId: poemId)
        } else {
            try await favorite(userId: userId, poemId: poemId)
        }
    }
    
    /// 获取我的收藏诗歌列表
    func fetchMyFavorites(userId: String) async throws -> [String] {
        let favorites: [Favorite] = try await client.request(
            method: .get,
            path: SupabaseConfig.favoritesTable,
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userId)"),
                URLQueryItem(name: "select", value: "poem_id"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )
        
        return favorites.map { $0.poemId }
    }
    
    // MARK: - 评论
    
    /// 获取诗歌的评论列表
    func fetchComments(poemId: String) async throws -> [Comment] {
        let comments: [Comment] = try await client.request(
            method: .get,
            path: SupabaseConfig.commentsTable,
            queryItems: [
                URLQueryItem(name: "poem_id", value: "eq.\(poemId)"),
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )
        
        return comments
    }
    
    /// 添加评论
    func addComment(userId: String, poemId: String, content: String) async throws {
        let request = CreateCommentRequest(
            userId: userId,
            poemId: poemId,
            content: content
        )
        
        let _: [Comment] = try await client.request(
            method: .post,
            path: SupabaseConfig.commentsTable,
            body: request
        )
    }
    
    /// 删除评论
    func deleteComment(id: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await client.request(
            method: .delete,
            path: "\(SupabaseConfig.commentsTable)?id=eq.\(id)"
        )
    }
}

