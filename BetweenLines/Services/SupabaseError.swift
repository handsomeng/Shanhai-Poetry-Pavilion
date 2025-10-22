//
//  SupabaseError.swift
//  山海诗馆
//
//  Supabase 错误定义
//

import Foundation

/// Supabase API 错误
enum SupabaseError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String?)
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case networkError(Error)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "服务器响应无效"
        case .httpError(let code, let message):
            return "请求失败 (\(code)): \(message ?? "未知错误")"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .encodingError(let error):
            return "数据编码失败: \(error.localizedDescription)"
        case .unauthorized:
            return "未授权，请先登录"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .unknown(let message):
            return message
        }
    }
}

