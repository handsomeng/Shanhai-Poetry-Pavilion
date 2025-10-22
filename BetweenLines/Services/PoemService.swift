//
//  PoemService.swift
//  山海诗馆
//
//  诗歌服务 - 使用 Supabase REST API
//

import Foundation

/// 诗歌服务
@MainActor
class PoemService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 广场诗歌列表
    @Published var squarePoems: [SquarePoem] = []
    
    /// 我的诗歌列表
    @Published var myPoems: [RemotePoem] = []
    
    /// 是否正在加载
    @Published var isLoading = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = PoemService()
    
    private let client = SupabaseHTTPClient.shared
    
    private init() {}
    
    // MARK: - 获取诗歌
    
    /// 获取广场诗歌（最新）
    func fetchSquarePoems(limit: Int = 50) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let poems: [SquarePoem] = try await client.request(
                method: .get,
                path: SupabaseConfig.squarePoemsView,
                queryItems: [
                    URLQueryItem(name: "select", value: "*"),
                    URLQueryItem(name: "order", value: "created_at.desc"),
                    URLQueryItem(name: "limit", value: "\(limit)")
                ]
            )
            
            squarePoems = poems
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取广场诗歌（热门）
    func fetchPopularPoems(limit: Int = 50) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let poems: [SquarePoem] = try await client.request(
                method: .get,
                path: SupabaseConfig.squarePoemsView,
                queryItems: [
                    URLQueryItem(name: "select", value: "*"),
                    URLQueryItem(name: "order", value: "like_count.desc"),
                    URLQueryItem(name: "limit", value: "\(limit)")
                ]
            )
            
            squarePoems = poems
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取我的诗歌
    func fetchMyPoems(authorId: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let poems: [RemotePoem] = try await client.request(
                method: .get,
                path: SupabaseConfig.poemsTable,
                queryItems: [
                    URLQueryItem(name: "author_id", value: "eq.\(authorId)"),
                    URLQueryItem(name: "select", value: "*"),
                    URLQueryItem(name: "order", value: "created_at.desc")
                ]
            )
            
            myPoems = poems
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取单首诗歌
    func fetchPoem(id: String) async throws -> RemotePoem {
        let poems: [RemotePoem] = try await client.request(
            method: .get,
            path: SupabaseConfig.poemsTable,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(id)"),
                URLQueryItem(name: "select", value: "*")
            ]
        )
        
        guard let poem = poems.first else {
            throw SupabaseError.unknown("诗歌不存在")
        }
        
        return poem
    }
    
    // MARK: - 创建诗歌
    
    /// 发布诗歌到广场
    func publishPoem(
        authorId: String,
        title: String,
        content: String,
        style: String,
        tags: [String]? = nil
    ) async throws -> RemotePoem {
        
        let request = CreatePoemRequest(
            authorId: authorId,
            title: title,
            content: content,
            style: style,
            isPublic: true,
            tags: tags
        )
        
        let poems: [RemotePoem] = try await client.request(
            method: .post,
            path: SupabaseConfig.poemsTable,
            body: request
        )
        
        guard let poem = poems.first else {
            throw SupabaseError.unknown("发布失败")
        }
        
        return poem
    }
    
    /// 保存草稿
    func saveDraft(
        authorId: String,
        title: String,
        content: String,
        style: String,
        tags: [String]? = nil
    ) async throws -> RemotePoem {
        
        let request = CreatePoemRequest(
            authorId: authorId,
            title: title,
            content: content,
            style: style,
            isPublic: false,
            tags: tags
        )
        
        let poems: [RemotePoem] = try await client.request(
            method: .post,
            path: SupabaseConfig.poemsTable,
            body: request
        )
        
        guard let poem = poems.first else {
            throw SupabaseError.unknown("保存失败")
        }
        
        return poem
    }
    
    // MARK: - 更新诗歌
    
    /// 更新诗歌
    func updatePoem(id: String, updates: UpdatePoemRequest) async throws {
        let _: [RemotePoem] = try await client.request(
            method: .patch,
            path: "\(SupabaseConfig.poemsTable)?id=eq.\(id)",
            body: updates
        )
    }
    
    // MARK: - 删除诗歌
    
    /// 删除诗歌
    func deletePoem(id: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await client.request(
            method: .delete,
            path: "\(SupabaseConfig.poemsTable)?id=eq.\(id)"
        )
    }
}

