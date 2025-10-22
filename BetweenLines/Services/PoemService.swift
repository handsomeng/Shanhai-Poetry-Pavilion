//
//  PoemService.swift
//  山海诗馆
//
//  诗歌服务 - 管理诗歌的增删改查、点赞、收藏
//

import Foundation
import Supabase

/// 诗歌服务
@MainActor
class PoemService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 广场诗歌列表
    @Published var squarePoems: [RemotePoem] = []
    
    /// 我的已发布诗歌
    @Published var myPoems: [RemotePoem] = []
    
    /// 我的草稿
    @Published var myDrafts: [RemotePoem] = []
    
    /// 我收藏的诗歌
    @Published var myFavorites: [RemotePoem] = []
    
    /// 是否正在加载
    @Published var isLoading = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = PoemService()
    
    private init() {}
    
    // MARK: - 获取诗歌列表
    
    /// 获取广场诗歌（最新）
    /// - Parameter limit: 数量限制
    func fetchSquarePoems(limit: Int = 20) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // 从 square_poems 视图获取（已包含作者信息）
            squarePoems = try await supabase.database
                .from("square_poems")
                .select()
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            print("✅ 获取广场诗歌成功：\(squarePoems.count) 首")
            
        } catch {
            errorMessage = "获取诗歌失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    /// 获取热门诗歌（按点赞数排序）
    /// - Parameter limit: 数量限制
    func fetchPopularPoems(limit: Int = 20) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // 调用数据库函数 get_popular_poems
            let params = ["limit_count": limit]
            squarePoems = try await supabase.database
                .rpc("get_popular_poems", params: params)
                .execute()
                .value
            
            print("✅ 获取热门诗歌成功：\(squarePoems.count) 首")
            
        } catch {
            errorMessage = "获取热门诗歌失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    /// 获取随机诗歌
    func fetchRandomPoems(limit: Int = 20) async throws {
        // 先获取所有诗歌，然后打乱
        try await fetchSquarePoems(limit: limit * 2)
        squarePoems.shuffle()
        squarePoems = Array(squarePoems.prefix(limit))
    }
    
    /// 获取我的已发布诗歌
    func fetchMyPoems() async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            myPoems = try await supabase.database
                .from("poems")
                .select()
                .eq("author_id", value: userId.uuidString)
                .eq("is_published", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("✅ 获取我的诗歌成功：\(myPoems.count) 首")
            
        } catch {
            errorMessage = "获取我的诗歌失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    /// 获取我的草稿
    func fetchMyDrafts() async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            myDrafts = try await supabase.database
                .from("poems")
                .select()
                .eq("author_id", value: userId.uuidString)
                .eq("is_draft", value: true)
                .order("updated_at", ascending: false)
                .execute()
                .value
            
            print("✅ 获取我的草稿成功：\(myDrafts.count) 首")
            
        } catch {
            errorMessage = "获取草稿失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    /// 获取我收藏的诗歌
    func fetchMyFavorites() async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 先获取收藏的 poem_id
            let favorites: [String: String] = try await supabase.database
                .from("favorites")
                .select("poem_id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            let poemIds = favorites.compactMap { $0["poem_id"] }
            
            // 再获取诗歌详情
            if !poemIds.isEmpty {
                myFavorites = try await supabase.database
                    .from("poems")
                    .select()
                    .in("id", values: poemIds)
                    .execute()
                    .value
            } else {
                myFavorites = []
            }
            
            print("✅ 获取收藏成功：\(myFavorites.count) 首")
            
        } catch {
            errorMessage = "获取收藏失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - 创建/更新诗歌
    
    /// 创建诗歌（草稿）
    /// - Parameters:
    ///   - title: 标题
    ///   - content: 内容
    ///   - writingMode: 写作模式
    ///   - tags: 标签
    ///   - aiComment: AI 点评
    /// - Returns: 创建的诗歌
    func createPoem(
        title: String,
        content: String,
        writingMode: String? = nil,
        tags: [String] = [],
        aiComment: String? = nil
    ) async throws -> RemotePoem {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        let poemData: [String: AnyEncodable] = [
            "title": AnyEncodable(title),
            "content": AnyEncodable(content),
            "author_id": AnyEncodable(userId.uuidString),
            "writing_mode": AnyEncodable(writingMode),
            "tags": AnyEncodable(tags),
            "ai_comment": AnyEncodable(aiComment),
            "is_draft": AnyEncodable(true),
            "is_published": AnyEncodable(false)
        ]
        
        do {
            let poems: [RemotePoem] = try await supabase.database
                .from("poems")
                .insert(poemData)
                .select()
                .execute()
                .value
            
            guard let poem = poems.first else {
                throw PoemError.createFailed
            }
            
            print("✅ 创建诗歌成功：\(poem.title)")
            return poem
            
        } catch {
            throw PoemError.createFailed
        }
    }
    
    /// 更新诗歌
    /// - Parameter poem: 要更新的诗歌
    func updatePoem(_ poem: RemotePoem) async throws {
        guard AuthService.shared.currentUser?.id == poem.authorId else {
            throw AuthError.notAuthenticated
        }
        
        try await supabase.database
            .from("poems")
            .update(poem.updateDict)
            .eq("id", value: poem.id.uuidString)
            .execute()
        
        print("✅ 更新诗歌成功：\(poem.title)")
    }
    
    /// 发布诗歌到广场
    /// - Parameter poemId: 诗歌 ID
    func publishToSquare(poemId: UUID) async throws {
        let updateData: [String: AnyEncodable] = [
            "is_published": AnyEncodable(true),
            "is_draft": AnyEncodable(false)
        ]
        
        try await supabase.database
            .from("poems")
            .update(updateData)
            .eq("id", value: poemId.uuidString)
            .execute()
        
        print("✅ 发布诗歌成功")
    }
    
    /// 删除诗歌
    /// - Parameter poemId: 诗歌 ID
    func deletePoem(poemId: UUID) async throws {
        try await supabase.database
            .from("poems")
            .delete()
            .eq("id", value: poemId.uuidString)
            .execute()
        
        print("✅ 删除诗歌成功")
    }
    
    // MARK: - 点赞功能
    
    /// 点赞诗歌
    /// - Parameter poemId: 诗歌 ID
    func likePoem(poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        let likeData: [String: AnyEncodable] = [
            "user_id": AnyEncodable(userId.uuidString),
            "poem_id": AnyEncodable(poemId.uuidString)
        ]
        
        do {
            try await supabase.database
                .from("likes")
                .insert(likeData)
                .execute()
            
            print("✅ 点赞成功")
            
            // 更新本地诗歌的点赞数
            await updateLocalLikeStatus(poemId: poemId, isLiked: true)
            
        } catch {
            // 如果是重复点赞，忽略错误
            if error.localizedDescription.contains("duplicate") {
                print("⚠️ 已经点过赞了")
            } else {
                throw PoemError.likeFailed
            }
        }
    }
    
    /// 取消点赞
    /// - Parameter poemId: 诗歌 ID
    func unlikePoem(poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        try await supabase.database
            .from("likes")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("poem_id", value: poemId.uuidString)
            .execute()
        
        print("✅ 取消点赞成功")
        
        // 更新本地诗歌的点赞状态
        await updateLocalLikeStatus(poemId: poemId, isLiked: false)
    }
    
    /// 切换点赞状态
    /// - Parameter poem: 诗歌
    func toggleLike(poem: RemotePoem) async throws {
        if poem.isLikedByMe == true {
            try await unlikePoem(poemId: poem.id)
        } else {
            try await likePoem(poemId: poem.id)
        }
    }
    
    // MARK: - 收藏功能
    
    /// 收藏诗歌
    /// - Parameter poemId: 诗歌 ID
    func favoritePoem(poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        let favoriteData: [String: AnyEncodable] = [
            "user_id": AnyEncodable(userId.uuidString),
            "poem_id": AnyEncodable(poemId.uuidString)
        ]
        
        try await supabase.database
            .from("favorites")
            .insert(favoriteData)
            .execute()
        
        print("✅ 收藏成功")
    }
    
    /// 取消收藏
    /// - Parameter poemId: 诗歌 ID
    func unfavoritePoem(poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        try await supabase.database
            .from("favorites")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("poem_id", value: poemId.uuidString)
            .execute()
        
        print("✅ 取消收藏成功")
    }
    
    // MARK: - 辅助方法
    
    /// 更新本地诗歌的点赞状态
    private func updateLocalLikeStatus(poemId: UUID, isLiked: Bool) async {
        // 更新 squarePoems 中的状态
        if let index = squarePoems.firstIndex(where: { $0.id == poemId }) {
            squarePoems[index].isLikedByMe = isLiked
            squarePoems[index].likeCount += isLiked ? 1 : -1
        }
    }
}

// MARK: - 错误类型

enum PoemError: LocalizedError {
    case createFailed
    case updateFailed
    case deleteFailed
    case likeFailed
    
    var errorDescription: String? {
        switch self {
        case .createFailed:
            return "创建诗歌失败"
        case .updateFailed:
            return "更新诗歌失败"
        case .deleteFailed:
            return "删除诗歌失败"
        case .likeFailed:
            return "点赞失败"
        }
    }
}

