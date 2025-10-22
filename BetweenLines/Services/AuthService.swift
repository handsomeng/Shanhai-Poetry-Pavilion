//
//  AuthService.swift
//  山海诗馆
//
//  认证服务 - 使用 Supabase REST API
//

import Foundation

/// 认证服务
@MainActor
class AuthService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 当前登录用户
    @Published var currentUser: AuthUser?
    
    /// 当前用户资料
    @Published var currentProfile: UserProfile?
    
    /// 是否已登录
    @Published var isAuthenticated = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = AuthService()
    
    private let client = SupabaseHTTPClient.shared
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults Keys
    private let accessTokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    private let userIdKey = "supabase_user_id"
    
    private init() {
        // 尝试从本地恢复 session
        restoreSession()
    }
    
    // MARK: - 注册
    
    /// 注册新用户
    func signUp(email: String, password: String, username: String) async throws {
        errorMessage = nil
        
        // 1. 调用 Auth API 注册
        let request = SignUpRequest(email: email, password: password)
        
        let response: AuthResponse = try await client.authRequest(
            method: .post,
            endpoint: "signup",
            body: request
        )
        
        // 2. 保存 tokens
        saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        client.accessToken = response.accessToken
        
        // 3. 创建用户资料
        let profileRequest = CreateProfileRequest(
            id: response.user.id,
            username: username,
            email: email
        )
        
        let profile: UserProfile = try await client.request(
            method: .post,
            path: SupabaseConfig.profilesTable,
            body: profileRequest
        )
        
        // 4. 更新状态
        currentUser = response.user
        currentProfile = profile
        isAuthenticated = true
    }
    
    // MARK: - 登录
    
    /// 登录
    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        
        // 1. 调用 Auth API 登录
        let request = SignInRequest(email: email, password: password)
        
        let response: AuthResponse = try await client.authRequest(
            method: .post,
            endpoint: "token?grant_type=password",
            body: request
        )
        
        // 2. 保存 tokens
        saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        client.accessToken = response.accessToken
        
        // 3. 获取用户资料
        let profiles: [UserProfile] = try await client.request(
            method: .get,
            path: SupabaseConfig.profilesTable,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(response.user.id)"),
                URLQueryItem(name: "select", value: "*")
            ]
        )
        
        guard let profile = profiles.first else {
            throw SupabaseError.unknown("用户资料不存在")
        }
        
        // 4. 更新状态
        currentUser = response.user
        currentProfile = profile
        isAuthenticated = true
    }
    
    // MARK: - 登出
    
    /// 登出
    func signOut() {
        // 清除本地数据
        userDefaults.removeObject(forKey: accessTokenKey)
        userDefaults.removeObject(forKey: refreshTokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        
        // 清除状态
        client.accessToken = nil
        currentUser = nil
        currentProfile = nil
        isAuthenticated = false
    }
    
    // MARK: - Session 管理
    
    /// 恢复 session
    private func restoreSession() {
        guard let accessToken = userDefaults.string(forKey: accessTokenKey),
              let userId = userDefaults.string(forKey: userIdKey) else {
            return
        }
        
        client.accessToken = accessToken
        
        // 异步加载用户资料
        Task {
            do {
                let profiles: [UserProfile] = try await client.request(
                    method: .get,
                    path: SupabaseConfig.profilesTable,
                    queryItems: [
                        URLQueryItem(name: "id", value: "eq.\(userId)"),
                        URLQueryItem(name: "select", value: "*")
                    ]
                )
                
                if let profile = profiles.first {
                    currentProfile = profile
                    currentUser = AuthUser(
                        id: userId,
                        email: profile.email,
                        createdAt: profile.createdAt
                    )
                    isAuthenticated = true
                }
            } catch {
                // Session 无效，清除
                signOut()
            }
        }
    }
    
    /// 保存 tokens
    private func saveTokens(accessToken: String, refreshToken: String) {
        userDefaults.set(accessToken, forKey: accessTokenKey)
        userDefaults.set(refreshToken, forKey: refreshTokenKey)
    }
    
    /// 保存用户 ID
    private func saveUserId(_ userId: String) {
        userDefaults.set(userId, forKey: userIdKey)
    }
}

