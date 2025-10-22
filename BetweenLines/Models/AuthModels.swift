//
//  AuthModels.swift
//  山海诗馆
//
//  认证相关数据模型
//

import Foundation

// MARK: - 认证响应

/// 认证响应（登录/注册）
struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let user: AuthUser
}

/// 认证用户信息
struct AuthUser: Codable {
    let id: String
    let email: String
    let createdAt: String
}

// MARK: - 用户资料

/// 用户资料（profiles 表）
struct UserProfile: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    var avatarUrl: String?
    var bio: String?
    var poetTitle: String
    var totalPoems: Int
    var totalLikes: Int
    var createdAt: String
    var updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case avatarUrl = "avatar_url"
        case bio
        case poetTitle = "poet_title"
        case totalPoems = "total_poems"
        case totalLikes = "total_likes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 认证请求

/// 注册请求
struct SignUpRequest: Codable {
    let email: String
    let password: String
}

/// 登录请求
struct SignInRequest: Codable {
    let email: String
    let password: String
}

/// 创建用户资料请求
struct CreateProfileRequest: Codable {
    let id: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
    }
}

