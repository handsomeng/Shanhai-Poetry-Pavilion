//
//  SupabaseConfig.swift
//  山海诗馆
//
//  Supabase 配置 - 无需 SDK，直接使用 REST API
//

import Foundation

/// Supabase 配置
enum SupabaseConfig {
    
    // MARK: - 基础配置
    
    /// Supabase 项目 URL
    static let projectURL = "https://bfudbchnwwckqryoiwst.supabase.co"
    
    /// Supabase Anon Public Key（客户端使用）
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmdWRiY2hud3dja3FyeW9pd3N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMjUxNjcsImV4cCI6MjA3NjcwMTE2N30.VMRbtiKRbSBuAzteG2h-mfDtA3wiY2YpJg76FSDQJ7w"
    
    // MARK: - API 端点
    
    /// REST API 基础 URL
    static let restURL = "\(projectURL)/rest/v1"
    
    /// Auth API 基础 URL
    static let authURL = "\(projectURL)/auth/v1"
    
    // MARK: - 表名
    
    /// 用户资料表
    static let profilesTable = "profiles"
    
    /// 诗歌表
    static let poemsTable = "poems"
    
    /// 点赞表
    static let likesTable = "likes"
    
    /// 收藏表
    static let favoritesTable = "favorites"
    
    /// 评论表
    static let commentsTable = "comments"
    
    /// 广场诗歌视图
    static let squarePoemsView = "square_poems"
}

