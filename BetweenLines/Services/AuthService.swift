//
//  AuthService.swift
//  山海诗馆
//
//  认证服务 - 管理用户登录/注册/登出
//

import Foundation
import Supabase

/// 认证服务
@MainActor
class AuthService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 当前登录的用户（Supabase Auth）
    @Published var currentUser: User?
    
    /// 当前用户资料（从 profiles 表）
    @Published var currentProfile: UserProfile?
    
    /// 是否已登录
    @Published var isAuthenticated = false
    
    /// 是否正在加载
    @Published var isLoading = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = AuthService()
    
    private init() {
        // 初始化时检查登录状态
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - 认证状态检查
    
    /// 检查当前登录状态
    func checkAuthStatus() async {
        do {
            // 获取当前 session
            let session = try await supabase.auth.session
            currentUser = session.user
            
            if currentUser != nil {
                // 如果已登录，获取用户资料
                await fetchUserProfile()
                isAuthenticated = true
            } else {
                isAuthenticated = false
            }
        } catch {
            print("检查登录状态失败：\(error.localizedDescription)")
            isAuthenticated = false
        }
    }
    
    /// 获取用户资料
    private func fetchUserProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let profiles: [UserProfile] = try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .execute()
                .value
            
            currentProfile = profiles.first
        } catch {
            print("获取用户资料失败：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 邮箱注册/登录
    
    /// 邮箱注册
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码（至少6位）
    ///   - username: 用户名（2-20字符）
    func signUpWithEmail(email: String, password: String, username: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // 验证输入
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw AuthError.invalidInput
        }
        
        guard password.count >= 6 else {
            throw AuthError.passwordTooShort
        }
        
        guard username.count >= 2 && username.count <= 20 else {
            throw AuthError.invalidUsername
        }
        
        do {
            // 1. 注册用户（Supabase Auth）
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            guard let user = response.user else {
                throw AuthError.registrationFailed
            }
            
            // 2. 创建用户资料（profiles 表）
            try await createUserProfile(userId: user.id, username: username)
            
            // 3. 更新本地状态
            currentUser = user
            await fetchUserProfile()
            isAuthenticated = true
            
            print("✅ 注册成功！用户名：\(username)")
            
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            throw error
        } catch {
            errorMessage = "注册失败：\(error.localizedDescription)"
            throw AuthError.registrationFailed
        }
    }
    
    /// 邮箱登录
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            currentUser = session.user
            await fetchUserProfile()
            isAuthenticated = true
            
            print("✅ 登录成功！")
            
        } catch {
            errorMessage = "登录失败：用户名或密码错误"
            throw AuthError.loginFailed
        }
    }
    
    // MARK: - 第三方登录
    
    /// Apple 登录
    /// ⚠️ 需要配置 Apple Sign In
    func signInWithApple() async throws {
        // TODO: 实现 Apple 登录
        // 需要配置 Apple Developer 和 Supabase
        throw AuthError.notImplemented
    }
    
    // MARK: - 登出
    
    /// 登出
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            
            // 清空本地状态
            currentUser = nil
            currentProfile = nil
            isAuthenticated = false
            
            print("✅ 登出成功")
            
        } catch {
            errorMessage = "登出失败：\(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - 辅助方法
    
    /// 创建用户资料
    /// - Parameters:
    ///   - userId: 用户 ID（从 Auth 获取）
    ///   - username: 用户名
    private func createUserProfile(userId: UUID, username: String) async throws {
        let profileData: [String: AnyEncodable] = [
            "id": AnyEncodable(userId.uuidString),
            "username": AnyEncodable(username),
            "display_name": AnyEncodable(username),  // 默认显示名称和用户名相同
            "poet_title": AnyEncodable("初见诗人")
        ]
        
        try await supabase.database
            .from("profiles")
            .insert(profileData)
            .execute()
    }
    
    /// 更新用户资料
    /// - Parameter profile: 新的用户资料
    func updateProfile(_ profile: UserProfile) async throws {
        guard currentUser?.id == profile.id else {
            throw AuthError.notAuthenticated
        }
        
        try await supabase.database
            .from("profiles")
            .update(profile.updateDict)
            .eq("id", value: profile.id.uuidString)
            .execute()
        
        // 重新获取资料
        await fetchUserProfile()
    }
}

// MARK: - 错误类型

enum AuthError: LocalizedError {
    case invalidInput
    case passwordTooShort
    case invalidUsername
    case registrationFailed
    case loginFailed
    case notAuthenticated
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "请填写完整信息"
        case .passwordTooShort:
            return "密码至少需要6位"
        case .invalidUsername:
            return "用户名长度需在2-20字符之间"
        case .registrationFailed:
            return "注册失败，该邮箱可能已被使用"
        case .loginFailed:
            return "登录失败，请检查邮箱和密码"
        case .notAuthenticated:
            return "请先登录"
        case .notImplemented:
            return "该功能暂未实现"
        }
    }
}

