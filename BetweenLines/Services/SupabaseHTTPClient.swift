//
//  SupabaseHTTPClient.swift
//  山海诗馆
//
//  Supabase HTTP 客户端 - 使用原生 URLSession
//

import Foundation

/// HTTP 方法
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Supabase HTTP 客户端
class SupabaseHTTPClient {
    
    /// 单例
    static let shared = SupabaseHTTPClient()
    
    /// URL Session
    private let session: URLSession
    
    /// 当前用户的 access token
    var accessToken: String?
    
    // MARK: - Network Permission Check
    
    /// 测试网络连接并触发权限请求
    /// 在登录前调用，确保网络权限已授予
    static func ensureNetworkPermission() async -> Bool {
        do {
            // 发送一个简单的 HEAD 请求到 Supabase
            guard let url = URL(string: SupabaseConfig.projectURL) else {
                return false
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 5
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [网络检测] 网络连接正常，状态码: \(httpResponse.statusCode)")
                return true
            }
            
            return false
        } catch {
            print("⚠️ [网络检测] 网络请求失败: \(error.localizedDescription)")
            // 即使失败也返回 true，因为这可能是正常的网络问题
            // 重点是触发了权限请求
            return true
        }
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - REST API 请求
    
    /// 执行 REST API 请求
    func request<T: Decodable>(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        
        // 构建 URL
        guard var urlComponents = URLComponents(string: "\(SupabaseConfig.restURL)/\(path)") else {
            throw SupabaseError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw SupabaseError.invalidURL
        }
        
        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 添加头部
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 如果有 access token，添加认证头
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        }
        
        // 添加请求体
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw SupabaseError.encodingError(error)
            }
        }
        
        // 发送请求
        do {
            let (data, response) = try await session.data(for: request)
            
            // 检查响应
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SupabaseError.invalidResponse
            }
            
            // 检查状态码
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw SupabaseError.httpError(httpResponse.statusCode, errorMessage)
            }
            
            // 解析响应
            do {
                // 打印原始响应数据（用于调试）
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 [DEBUG] 原始响应: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                // 不使用 convertFromSnakeCase，因为我们在模型中手动定义了 CodingKeys
                // decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ [DEBUG] 解码失败: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ [DEBUG] 详细错误: \(decodingError)")
                }
                throw SupabaseError.decodingError(error)
            }
            
        } catch let error as SupabaseError {
            throw error
        } catch {
            throw SupabaseError.networkError(error)
        }
    }
    
    // MARK: - Auth API 请求
    
    /// 执行 Auth API 请求
    func authRequest<T: Decodable>(
        method: HTTPMethod,
        endpoint: String,
        body: Encodable? = nil
    ) async throws -> T {
        
        // 构建 URL
        guard let url = URL(string: "\(SupabaseConfig.authURL)/\(endpoint)") else {
            throw SupabaseError.invalidURL
        }
        
        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 添加头部
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 如果有 access token，添加认证头
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // 添加请求体
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw SupabaseError.encodingError(error)
            }
        }
        
        // 发送请求
        do {
            let (data, response) = try await session.data(for: request)
            
            // 检查响应
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SupabaseError.invalidResponse
            }
            
            // 检查状态码
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw SupabaseError.httpError(httpResponse.statusCode, errorMessage)
            }
            
            // 解析响应
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw SupabaseError.decodingError(error)
            }
            
        } catch let error as SupabaseError {
            throw error
        } catch {
            throw SupabaseError.networkError(error)
        }
    }
}

