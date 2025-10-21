//
//  ErrorHandler.swift
//  BetweenLines - 山海诗馆
//
//  统一错误处理机制
//

import Foundation
import SwiftUI

// MARK: - 应用错误类型

enum AppError: LocalizedError {
    // 网络错误
    case networkUnavailable
    case requestTimeout
    case serverError(Int)
    case invalidResponse
    
    // AI 错误
    case aiAPIKeyMissing
    case aiRequestFailed(String)
    case aiResponseInvalid
    
    // 数据错误
    case saveFailed
    case loadFailed
    case deleteFailed
    case dataCorrupted
    
    // 输入验证错误
    case emptyContent
    case contentTooShort(min: Int)
    case contentTooLong(max: Int)
    case invalidFormat
    
    // 其他
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        // 网络错误
        case .networkUnavailable:
            return "网络不可用，请检查网络连接"
        case .requestTimeout:
            return "请求超时，请稍后重试"
        case .serverError(let code):
            return "服务器错误 (\(code))，请稍后重试"
        case .invalidResponse:
            return "服务器返回数据格式错误"
            
        // AI 错误
        case .aiAPIKeyMissing:
            return "请先在设置中配置 OpenAI API Key"
        case .aiRequestFailed(let message):
            return "AI 请求失败：\(message)"
        case .aiResponseInvalid:
            return "AI 返回数据无效，请重试"
            
        // 数据错误
        case .saveFailed:
            return "保存失败，请重试"
        case .loadFailed:
            return "加载数据失败"
        case .deleteFailed:
            return "删除失败，请重试"
        case .dataCorrupted:
            return "数据已损坏，建议重置应用"
            
        // 输入验证
        case .emptyContent:
            return "内容不能为空"
        case .contentTooShort(let min):
            return "内容至少需要 \(min) 个字符"
        case .contentTooLong(let max):
            return "内容不能超过 \(max) 个字符"
        case .invalidFormat:
            return "格式不正确"
            
        // 其他
        case .unknown(let message):
            return message.isEmpty ? "未知错误" : message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "请检查 Wi-Fi 或移动网络连接"
        case .requestTimeout:
            return "网络较慢，建议稍后再试"
        case .serverError:
            return "服务器暂时无法响应，请稍后重试"
        case .aiAPIKeyMissing:
            return "前往 我的 → 设置 配置 API Key"
        case .aiRequestFailed:
            return "检查 API Key 是否正确，或稍后重试"
        case .dataCorrupted:
            return "前往 设置 → 数据管理 → 重置数据"
        default:
            return nil
        }
    }
}

// MARK: - 错误处理器

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showError = false
    
    private init() {}
    
    /// 显示错误
    func handle(_ error: Error, file: String = #file, line: Int = #line) {
        // 日志记录（生产环境可替换为专业日志服务）
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("❌ 错误 [\(fileName):\(line)]: \(error.localizedDescription)")
        #endif
        
        // 转换为 AppError
        if let appError = error as? AppError {
            currentError = appError
        } else if let urlError = error as? URLError {
            currentError = mapURLError(urlError)
        } else {
            currentError = .unknown(error.localizedDescription)
        }
        
        showError = true
    }
    
    /// 显示特定错误
    func show(_ error: AppError) {
        currentError = error
        showError = true
    }
    
    /// 清除错误
    func clear() {
        currentError = nil
        showError = false
    }
    
    /// 映射 URLError 到 AppError
    private func mapURLError(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .requestTimeout
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - SwiftUI 扩展：错误处理修饰符

extension View {
    /// 统一错误处理 Modifier
    func withErrorHandling() -> some View {
        self.modifier(ErrorHandlingModifier())
    }
}

struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.currentError?.errorDescription ?? "发生错误",
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { _ in
                Button("确定", role: .cancel) {
                    errorHandler.clear()
                }
            } message: { error in
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
    }
}

// MARK: - 加载状态管理器

@MainActor
class LoadingStateManager: ObservableObject {
    static let shared = LoadingStateManager()
    
    @Published var isLoading = false
    @Published var loadingMessage: String?
    
    private init() {}
    
    /// 开始加载
    func start(_ message: String? = nil) {
        isLoading = true
        loadingMessage = message
    }
    
    /// 结束加载
    func stop() {
        isLoading = false
        loadingMessage = nil
    }
    
    /// 执行带加载状态的异步任务
    func perform<T>(
        message: String? = nil,
        action: @escaping () async throws -> T
    ) async throws -> T {
        start(message)
        defer { stop() }
        return try await action()
    }
}

// MARK: - SwiftUI 扩展：加载状态

extension View {
    /// 显示加载指示器
    func withLoadingIndicator() -> some View {
        self.modifier(LoadingIndicatorModifier())
    }
}

struct LoadingIndicatorModifier: ViewModifier {
    @StateObject private var loadingState = LoadingStateManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(loadingState.isLoading)
            
            if loadingState.isLoading {
                ZStack {
                    Colors.backgroundCream
                        .opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Colors.accentTeal)
                        
                        if let message = loadingState.loadingMessage {
                            Text(message)
                                .font(Fonts.caption())
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                    .padding(Spacing.xl)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(Colors.border, lineWidth: 0.3)
                    )
                }
                .transition(.opacity)
            }
        }
    }
}

