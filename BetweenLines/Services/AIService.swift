//
//  AIService.swift
//  山海诗馆
//
//  AI 服务：调用 OpenAI API 进行诗歌点评
//

import Foundation

@MainActor
class AIService {
    
    static let shared = AIService()
    
    private init() {}
    
    /// 获取诗歌点评
    func getPoemComment(content: String) async throws -> String {
        let prompt = """
        请你作为一位专业的现代诗评论家，对以下诗歌进行点评。请从以下几个方面进行分析：
        
        1. 意象运用：诗中使用了哪些意象，是否新鲜有力？
        2. 情感表达：诗歌传递了什么样的情感或氛围？
        3. 语言特色：语言是否简洁有力，是否有过度修饰？
        4. 结构节奏：分行和节奏是否合理？
        5. 改进建议：给出1-2条具体的改进建议
        
        诗歌内容：
        \(content)
        
        请用温和、鼓励的语气进行点评，字数控制在200字左右。
        """
        
        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                ["role": "system", "content": "你是一位专业且友善的现代诗评论家，擅长用简洁易懂的语言帮助初学者提升诗歌创作水平。"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": AppConstants.openAIMaxTokens,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: AppConstants.openAIBaseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(AppConstants.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = AppConstants.openAITimeout
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parseError
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 获取创作建议
    func getWritingSuggestion(theme: String) async throws -> String {
        let prompt = """
        用户想要围绕「\(theme)」这个主题创作一首现代诗。
        请提供3-5个具体的创作建议，包括：
        - 可以使用的意象
        - 可以表达的情感角度
        - 简短的示例句子
        
        请用简洁、启发性的语言，字数控制在150字左右。
        """
        
        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                ["role": "system", "content": "你是一位富有创造力的诗歌导师，擅长激发创作灵感。"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500,
            "temperature": 0.8
        ]
        
        guard let url = URL(string: AppConstants.openAIBaseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(AppConstants.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = AppConstants.openAITimeout
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parseError
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - AI Error

enum AIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case parseError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 API 地址"
        case .invalidResponse:
            return "服务器响应无效"
        case .httpError(let code):
            return "请求失败（错误代码：\(code)）"
        case .parseError:
            return "数据解析失败"
        case .networkError:
            return "网络连接失败"
        }
    }
}

