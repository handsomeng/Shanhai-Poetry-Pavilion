//
//  AuthService.swift
//  山海诗馆
//
//  认证服务 - 使用 Supabase REST API
//

import Foundation
import Combine
import AuthenticationServices

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
            displayName: nil  // 邮箱注册不提供显示名称
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
    
    // MARK: - Apple 登录
    
    /// Apple Sign In
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        errorMessage = nil
        
        // 1. 获取必要信息
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw SupabaseError.unknown("无法获取 Apple ID Token")
        }
        
        let userId = credential.user
        
        // 2. 构建请求体
        struct AppleSignInRequest: Codable {
            let provider: String
            let idToken: String
            
            enum CodingKeys: String, CodingKey {
                case provider
                case idToken = "id_token"
            }
        }
        
        let request = AppleSignInRequest(
            provider: "apple",
            idToken: tokenString
        )
        
        // 3. 调用 Supabase Auth API
        let response: AuthResponse = try await client.authRequest(
            method: .post,
            endpoint: "token?grant_type=id_token",
            body: request
        )
        
        // 4. 保存 tokens
        saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        saveUserId(response.user.id)
        client.accessToken = response.accessToken
        
        // 5. 检查用户资料是否存在
        let profiles: [UserProfile] = try await client.request(
            method: .get,
            path: SupabaseConfig.profilesTable,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(response.user.id)"),
                URLQueryItem(name: "select", value: "*")
            ]
        )
        
        if let profile = profiles.first {
            // 用户资料已存在
            currentProfile = profile
        } else {
            // 首次登录，创建用户资料
            let username: String
            let displayName: String?
            
            if let fullName = credential.fullName {
                // 使用 Apple 提供的姓名
                let givenName = fullName.givenName ?? ""
                let familyName = fullName.familyName ?? ""
                
                if !givenName.isEmpty || !familyName.isEmpty {
                    username = "诗人\(String(userId.prefix(6)))"
                    displayName = (familyName + givenName)
                } else {
                    username = "诗人\(String(userId.prefix(6)))"
                    displayName = nil
                }
            } else {
                // 使用默认用户名
                username = "诗人\(String(userId.prefix(6)))"
                displayName = nil
            }
            
            let profileRequest = CreateProfileRequest(
                id: response.user.id,
                username: username,
                displayName: displayName
            )
            
            let profile: UserProfile = try await client.request(
                method: .post,
                path: SupabaseConfig.profilesTable,
                body: profileRequest
            )
            
            currentProfile = profile
        }
        
        // 6. 更新状态
        currentUser = response.user
        isAuthenticated = true
    }
    
    // MARK: - 邮箱登录
    
    /// 邮箱登录
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
                    // 注意：email 存储在 auth.users 表中，这里我们只需要恢复基本状态
                    // 实际的 user 信息会在需要时通过 API 获取
                    currentUser = AuthUser(
                        id: userId,
                        email: "",  // Session 恢复时不需要 email
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

