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
    
    /// 生成诗歌主题和引导（用于主题写诗）
    func generatePoemThemeWithGuidance() async throws -> PoemThemeResult {
        try validateAPIKey()
        
        // 添加时间戳增加随机性
        let timestamp = Date().timeIntervalSince1970
        
        let prompt = """
        请推荐一个适合写现代诗的创作主题，并提供创作引导。
        
        **重要**：
        - 每次都要推荐**完全不同**的主题，充分发挥创造力
        - 主题可以来自：自然、城市、情感、记忆、日常物件、抽象概念等各个领域
        - 避免重复常见主题，尽量新颖独特
        
        **要求**：
        1. 主题：2-5个字，具体而有诗意
        2. 引导：50字左右，提供创作角度、可用意象、情感方向等
        
        **主题类型参考**（每次随机选择不同类型）：
        - 自然现象：晨雾、春雨、星空、雪融、晚霞
        - 城市生活：地铁、咖啡馆、旧书店、天台、街角
        - 日常物件：旧信、镜子、钟表、窗帘、钥匙
        - 情感记忆：等待、告别、重逢、迷路、沉默
        - 抽象概念：时间、距离、回声、影子、边界
        
        **严格按以下 JSON 格式输出**：
        {
            "theme": "主题名称",
            "guidance": "创作引导内容（50字左右）"
        }
        
        **只输出 JSON，不要任何其他内容。**
        
        当前时间戳：\(Int(timestamp))（用于确保每次生成都不同）
        """
        
        let result = try await callAI(
            prompt: prompt,
            systemMessage: "你是一位富有创造力的诗歌导师，擅长给出启发性、多样化的创作主题和引导。每次都要推荐完全不同的主题，充分发挥想象力。",
            temperature: 1.2,
            maxTokens: 300
        )
        
        // 解析 JSON 结果
        guard let jsonData = result.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let theme = json["theme"] as? String,
              let guidance = json["guidance"] as? String else {
            // 如果解析失败，使用默认值
            return PoemThemeResult(theme: "日常片刻", guidance: "观察身边的小事物，捕捉瞬间的情感。可以从光影、声音、触感等感官入手，写出真实的感受。")
        }
        
        return PoemThemeResult(theme: theme, guidance: guidance)
    }
    
    /// 获取续写灵感（在创作卡壳时提供思路）
    func getWritingInspiration(currentContent: String, title: String = "") async throws -> String {
        try validateAPIKey()
        
        // 检查当前内容
        let trimmedContent = currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果内容太少，给出起步提示
        if trimmedContent.isEmpty {
            return """
            可以试试从一个具体的画面开始，比如窗外的雨、街角的猫、深夜的灯光。或者从此刻的情绪出发——孤独、喜悦、怀念、迷茫。
            
            先写下第一句，不要想太多，诗会自己生长出来的。
            """
        }
        
        let prompt = """
        用户正在创作一首现代诗，现在遇到了瓶颈，需要你像朋友一样给一些续写的思路。
        
        **关键要求**：
        1. 语气要像聊天，自然、随意、不装
        2. 不要用任何 markdown 格式（不要用**加粗**、不要用•项目符号、不要用###标题）
        3. 不要直接写诗句，只说思路
        4. 给 2-3 个方向就够了
        5. 50-80字，简短点
        6. 用换行分段，但不要用符号
        
        \(title.isEmpty ? "" : "标题是《\(title)》")
        
        已写内容：
        \(trimmedContent)
        
        **你的回复示例**（纯文字，无格式）：
        
        我觉得可以试试这几个方向。
        
        一是从"梦"这个意象延伸，写一些更具体的画面，比如醒来时手心的汗、枕头的温度。
        
        或者来个情感转折，从平静突然到波澜，形成反差。
        
        也可以留白收尾，让读者自己想象后面的事。
        """
        
        return try await callAI(
            prompt: prompt,
            systemMessage: "你是用户的创作伙伴，像朋友一样聊天。你的建议简洁、自然、有启发，但绝不会写诗句给他。你说话不用 markdown 格式，就是普通的聊天文字。",
            temperature: 0.8,
            maxTokens: 300
        )
    }
    
    /// 内容审核（用于发布到广场前）
    func moderateContent(title: String, content: String) async throws -> ContentModerationResult {
        try validateAPIKey()
        
        let prompt = """
        你是一位内容审核专员，需要审核以下诗歌是否适合发布到公开平台。
        
        **审核标准**（任何一条不通过即拒绝）：
        1. 字数检查：诗歌正文至少 10 个字（不含标题）
        2. 内容质量：不能全是符号、数字、乱码
        3. 语言文明：不包含脏话、辱骂、低俗内容
        4. 政治敏感：不涉及政治敏感话题、领导人、政治体制等
        5. 违法内容：不包含暴力、色情、赌博、毒品等违法内容
        6. 广告营销：不包含广告、营销、联系方式
        
        诗歌标题：\(title.isEmpty ? "（无标题）" : title)
        诗歌正文：
        \(content)
        
        **请严格按以下 JSON 格式输出审核结果**：
        {
            "pass": true/false,
            "reason": "如果不通过，简短说明原因（1-2句话）；如果通过，填 null"
        }
        
        **只输出 JSON，不要任何其他内容。**
        """
        
        let result = try await callAI(
            prompt: prompt,
            systemMessage: "你是一位严谨、公正的内容审核专员。你会客观评估内容是否符合社区规范，既不会过度宽松，也不会过度严格。",
            temperature: 0.3, // 低温度，确保审核稳定性
            maxTokens: 200
        )
        
        // 解析 JSON 结果
        guard let jsonData = result.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let pass = json["pass"] as? Bool else {
            // 如果解析失败，默认通过（避免误伤）
            return ContentModerationResult(pass: true, reason: nil)
        }
        
        let reason = json["reason"] as? String
        return ContentModerationResult(pass: pass, reason: reason)
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
    
    // MARK: - Poet Profile Analysis (Easter Egg)
    
    /// 分析诗人画像（隐藏彩蛋功能）
    /// - Parameter poems: 最近的诗歌列表（最多10首）
    /// - Returns: AI 生成的诗人画像分析
    func analyzePoetProfile(poems: [Poem]) async throws -> String {
        try validateAPIKey()
        
        // 如果诗歌太少
        if poems.count < 3 {
            return "你已经开始创作了，这很好！再多写几首诗，我就能更准确地了解你的创作风格和内心世界了。每一首诗都是你心灵的映射，期待看到更多作品~"
        }
        
        // 构建诗歌内容
        var poemsText = ""
        for (index, poem) in poems.enumerated() {
            poemsText += "【诗歌 \(index + 1)】\n"
            if !poem.title.isEmpty {
                poemsText += "标题：\(poem.title)\n"
            }
            poemsText += "\(poem.content)\n\n"
        }
        
        let prompt = """
        你是一位温暖、善解人意的诗歌心理分析师。用户通过连续点击 5 次标题触发了这个隐藏彩蛋，你需要基于 TA 最近创作的 \(poems.count) 首诗，给出一份诗人画像分析。
        
        **分析框架**：
        1. **创作风格**：TA 是什么类型的诗人？（如观察者、思考者、浪漫主义者、现实主义者等）
        2. **情感基调**：最近的心境如何？是平静、忧郁、喜悦、迷茫还是复杂交织？
        3. **关注主题**：TA 最常写什么？（自然、人际关系、孤独、成长、时间等）
        4. **内心洞察**：从诗歌中能看到 TA 可能没有意识到的内心活动或特质
        5. **正向反馈**：委婉、真诚地给予鼓励和肯定
        
        **语气要求**：
        - 像朋友般温暖、真诚，不要像心理医生或老师
        - 用第二人称"你"，拉近距离
        - 委婉表达，避免直白的判断
        - 多用"似乎"、"可能"、"或许"等柔和词汇
        - 即使看到消极情绪，也要正向引导
        - 200-300 字，不要太长
        - 不要用 markdown 格式
        - 自然分段，但不要用符号
        
        **诗歌内容**：
        \(poemsText)
        
        **示例风格**：
        
        你是一位细腻的观察者，善于从平凡的日常中捕捉诗意。你的诗里常常出现雨、窗、夜晚这些意象，它们像是你内心世界的投影——安静、沉思，偶尔带着一点孤独。
        
        最近你似乎在思考时间和记忆，你在用诗记录那些容易被遗忘的瞬间。这说明你是个珍惜当下的人，也可能正在经历某种内心的成长或转变。
        
        你的文字很真诚，不刻意雕琢，这种自然流露的情感反而更打动人。继续保持这份真实，你的诗会越写越好的。
        """
        
        return try await callAI(
            prompt: prompt,
            systemMessage: "你是一位温暖、善解人意的诗歌心理分析师，擅长从诗歌中洞察创作者的内心世界，并给予真诚、正向的反馈。你说话自然、亲切，像朋友一样。",
            temperature: 0.8,
            maxTokens: 600
        )
    }
}

// MARK: - Poem Theme Result

/// 诗歌主题生成结果
struct PoemThemeResult {
    let theme: String      // 主题名称
    let guidance: String   // 创作引导
}

// MARK: - Content Moderation Result

/// 内容审核结果
struct ContentModerationResult {
    let pass: Bool       // 是否通过审核
    let reason: String?  // 如果不通过，原因是什么
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

