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
    
    /// 获取当前 API Key（优先从设置读取，否则使用默认值）
    private var apiKey: String {
        let savedKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.openAIAPIKey)
        return savedKey?.isEmpty == false ? savedKey! : AppConstants.openAIAPIKey
    }
    
    /// 验证 API Key
    private func validateAPIKey() throws {
        guard !apiKey.isEmpty, apiKey.hasPrefix("sk-") else {
            throw AppError.aiAPIKeyMissing
        }
    }
    
    /// 获取诗歌点评
    func getPoemComment(content: String) async throws -> String {
        try validateAPIKey()
        
        // 检查内容长度，太短则提示
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = trimmedContent.count
        
        if wordCount < 10 {
            return "诗歌内容似乎还不太完整呢。建议先完整地写下你的想法和感受，再来点评会更有帮助。现代诗虽然可以很短，但也需要有完整的意境和表达哦。"
        }
        
        let prompt = """
        你是一位专业的现代诗评论家，需要对以下诗歌进行中肯的点评。

        **评价原则**：
        1. 先判断这是否是一首完整的诗（是否有诗的意象、节奏、情感）
        2. 如果只是随意的文字或不完整，委婉提醒作者"可以写得更完整些再点评"
        3. 如果是完整的诗，遵循"先肯定亮点 → 再指出不足 → 后给建议"的结构
        4. 不要过度夸奖，要实事求是
        5. 改进建议要具体、可操作
        
        **评价维度**（如果是完整的诗）：
        - 意象：是否新鲜？是否陈词滥调？
        - 情感：是否真挚？是否流于表面？
        - 语言：是否简练？是否过度修饰？
        - 结构：分行是否合理？节奏是否流畅？
        - 深度：是否有思考和层次？
        
        诗歌内容：
        \(content)
        
        请用专业、温和但不讨好的语气点评，字数控制在150-200字。
        如果诗歌质量较低，可以坦诚指出问题，但语气要鼓励而非打击。
        """
        
        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                ["role": "system", "content": "你是一位严谨而温和的现代诗评论家。你既能看到作品的闪光点，也能指出需要改进的地方。你的点评实事求是，既不过度夸奖，也不过分苛刻，目标是帮助创作者真正提升。"],
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
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
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
    
    /// 生成示例诗歌（用于模仿写诗）
    func generateExamplePoem() async throws -> String {
        try validateAPIKey()
        
        let prompt = """
        请创作一首优秀的现代诗，用于教学示范。
        
        要求：
        1. 长度：20-50字左右，不要太长
        2. 风格：简洁、意象鲜明、情感真挚
        3. 技巧：展示优秀的分行、节奏、留白
        4. 主题：日常生活、情感、自然等都可以
        5. 避免陈词滥调，追求新鲜感
        
        **只输出诗歌内容本身，不要标题，不要任何解释说明。**
        """
        
        return try await callAI(
            prompt: prompt,
            systemMessage: "你是一位优秀的现代诗人，擅长创作简洁而富有诗意的作品。",
            temperature: 0.9,
            maxTokens: 300
        )
    }
    
    /// 生成诗歌主题（用于主题写诗）
    func generatePoemTheme() async throws -> String {
        try validateAPIKey()
        
        let prompt = """
        请推荐一个适合写现代诗的创作主题。
        
        要求：
        1. 主题要具体而有诗意（如"雨后的窗"、"城市夜晚"、"等待"）
        2. 不要太抽象（避免"人生"、"梦想"这类）
        3. 能激发具体的意象和情感
        4. 2-5个字，简洁有力
        
        **只输出主题本身，不要任何解释。**
        
        示例格式：
        城市夜晚
        雨后的窗
        孤独的树
        """
        
        return try await callAI(
            prompt: prompt,
            systemMessage: "你是一位富有创造力的诗歌导师，擅长给出启发性的创作主题。",
            temperature: 1.0,
            maxTokens: 50
        )
    }
    
    /// 通用 AI 调用方法
    private func callAI(
        prompt: String,
        systemMessage: String,
        temperature: Double = 0.7,
        maxTokens: Int = 500
    ) async throws -> String {
        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens,
            "temperature": temperature
        ]
        
        guard let url = URL(string: AppConstants.openAIBaseURL) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
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

