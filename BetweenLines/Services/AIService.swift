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
    
    /// 获取诗歌点评（深度分析版）
    func getPoemComment(content: String) async throws -> String {
        try validateAPIKey()
        
        // 检查内容长度，太短则提示
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = trimmedContent.count
        
        if wordCount < 10 {
            return "诗歌内容似乎还不太完整呢。建议先完整地写下你的想法和感受，再来点评会更有帮助。现代诗虽然可以很短，但也需要有完整的意境和表达哦。"
        }
        
        // 将内容按行分割，便于分析
        let lines = trimmedContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let prompt = """
        你是一位专业的现代诗评论家，需要对以下诗歌进行深度的、中肯的点评。

        **评价原则**：
        1. 先判断这是否是一首完整的诗（是否有诗的意象、节奏、情感）
        2. 如果只是随意的文字或不完整，委婉提醒作者"可以写得更完整些再点评"
        3. 如果是完整的诗，必须进行深度分析，遵循"先肯定亮点 → 深度分析问题 → 给出锋利建议"的结构
        4. 不要过度夸奖，要实事求是，但也要看到闪光点
        5. 改进建议要具体、可操作、有针对性
        
        **深度分析维度**（如果是完整的诗，必须全部覆盖）：
        
        1. **理解意图**
           - 这首诗想表达什么情感或主题？
           - 诗歌的整体氛围和基调是什么？
           - 是否有明确的意象体系或画面？
        
        2. **用词分析**
           - 哪些词用得很好？为什么？（具体指出1-2个词，说明好在哪里）
           - 哪些词有改进空间？为什么？（具体指出1-2个词，说明问题在哪里）
           - 是否有陈词滥调或过于常见的表达？
           - 用词是否精准、有力？
        
        3. **意象系统检查**
           - 意象是否统一？是否形成了完整的意象体系？
           - 是否有意象跳跃过大、不连贯的问题？
           - 意象是否具体、可感？还是过于抽象？
           - 意象是否新鲜？是否陈词滥调？
        
        4. **语言问题诊断**
           - 是否出现解释性句式？（如"因为...所以..."、"这意味着..."、"就像..."等）
           - 是否有抽象词污染？（如"美好"、"幸福"、"痛苦"、"悲伤"等空洞的抽象词）
           - 是否过度修饰？语言是否简练有力？
           - 是否有冗余的表达？
        
        5. **结构分析**
           - 分行是否合理？节奏是否流畅？
           - 最弱的一行是哪一行？为什么弱？（必须明确指出第几行）
           - 是否有冗余或可以删除的部分？
           - 整体结构是否有层次？是否有递进或转折？
        
        6. **情感与深度**
           - 情感是否真挚？是否流于表面？
           - 是否有思考和层次？还是只是简单的情绪表达？
           - 是否有独特的视角或洞察？
        
        **输出格式要求**：
        - 不要用 markdown 格式（不要用**加粗**、不要用•项目符号、不要用###标题）
        - 用换行分段，但不要用符号
        - 语气专业但友好，像一位经验丰富的创作导师
        - 总字数控制在250-350字
        - 结构：先肯定亮点 → 深度分析问题（必须指出具体问题） → 给出锋利的修改建议
        
        **诗歌内容**（共\(lines.count)行）：
        \(lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        **输出示例风格**（纯文字，无格式）：
        
        这首诗想表达的是...（理解意图）
        
        用词方面，"XX"这个词很好，因为...；但"XX"可以改进，因为...
        
        意象上，你用了...，整体是统一的/有跳跃。建议...
        
        语言上，第X行出现了解释性句式/抽象词"XX"，建议改为更具体的表达，比如...
        
        结构上，第X行相对较弱，因为...，可以考虑删除/改为...
        
        整体来说，这首诗的亮点是...，但需要改进的是...。建议...
        """
        
        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                ["role": "system", "content": "你是一位专业的现代诗评论家，擅长深度分析诗歌创作。你既能看到作品的闪光点，也能犀利地指出问题，给出具体、可操作的改进建议。你说话专业但友好，实事求是，既不过度夸奖，也不过分苛刻，目标是帮助创作者真正提升。你说话不用 markdown 格式，就是清晰的文字分析。"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 800,
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
        请推荐一个适合写现代诗的创作主题，并提供实用的创作引导。
        
        **核心原则**：
        - 主题要**贴近日常生活**，让人有共鸣，容易产生画面感
        - 避免过于抽象、冷门或学术化的主题（如"夜光藻"、"量子纠缠"等）
        - 优先选择：日常场景、常见物件、真实情感、生活片段
        - 每次推荐不同的主题，但要保证都是接地气的、可感知的
        
        **主题要求**：
        1. 主题：2-5个字，具体、日常、有画面感
        2. 引导：60-80字，要**实用具体**，包括：
           - 可以从什么角度写（观察点）
           - 可以用哪些具体的意象（不要抽象词汇）
           - 可以表达什么情感（真实可感）
           - 给出1-2个具体的写作建议
        
        **推荐主题类型**（优先选择这些，保证落地）：
        - 日常场景：清晨的厨房、深夜的便利店、雨天的公交站、午后的阳台
        - 常见物件：旧手机、外卖盒、晾衣绳、充电器、空杯子
        - 生活片段：等电梯、刷手机、找钥匙、关灯、倒垃圾
        - 真实情感：想家、失眠、无聊、小确幸、失落
        - 自然日常：窗外的树、阳台的花、路边的猫、雨后的街
        
        **引导示例**（参考这种风格）：
        - 主题："深夜便利店"
        - 引导："观察便利店里的细节：冷柜的灯光、收银台的声响、货架上的商品。可以写孤独感，也可以写温暖感。试试从'推门进去'这个动作开始，或者从'结账时'的瞬间写起。"
        
        **严格按以下 JSON 格式输出**：
        {
            "theme": "主题名称",
            "guidance": "创作引导内容（60-80字，要具体实用）"
        }
        
        **只输出 JSON，不要任何其他内容。**
        
        当前时间戳：\(Int(timestamp))（用于确保每次生成都不同）
        """
        
        let result = try await callAI(
            prompt: prompt,
            systemMessage: "你是一位接地气的诗歌创作导师，擅长给出贴近日常生活的、实用的创作主题和引导。你推荐的主题都是人们熟悉的生活场景和真实感受，让人能立即产生画面感和创作冲动。",
            temperature: 0.9,
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
    
    /// 获取续写灵感和深度创作建议（在创作时提供专业分析）
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
        
        // 将内容按行分割，便于分析
        let lines = trimmedContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let prompt = """
        你是一位专业的现代诗创作导师，用户正在创作一首诗，需要你提供深度的创作建议和续写思路。
        
        **核心任务**：
        深度理解用户想表达什么，分析现有内容的优缺点，给出锋利的修改建议和续写方向。
        
        **分析维度**（必须全部覆盖）：
        
        1. **理解意图**
           - 用户想表达什么情感或主题？
           - 诗歌的整体氛围是什么？
           - 是否有明确的意象或画面？
        
        2. **用词分析**
           - 哪些词用得很好？为什么？（具体指出1-2个词）
           - 哪些词有改进空间？为什么？（具体指出1-2个词）
           - 是否有陈词滥调或过于常见的表达？
        
        3. **意象系统检查**
           - 意象是否统一？是否形成了完整的意象体系？
           - 是否有意象跳跃过大、不连贯的问题？
           - 意象是否具体、可感？还是过于抽象？
        
        4. **语言问题诊断**
           - 是否出现解释性句式？（如"因为...所以..."、"这意味着..."等）
           - 是否有抽象词污染？（如"美好"、"幸福"、"痛苦"等空洞的抽象词）
           - 是否过度修饰？语言是否简练有力？
        
        5. **结构分析**
           - 分行是否合理？节奏是否流畅？
           - 最弱的一行是哪一行？为什么弱？（必须明确指出）
           - 是否有冗余或可以删除的部分？
        
        6. **续写建议**
           - 基于以上分析，给出2-3个具体的续写方向
           - 每个方向要具体、可操作，不要泛泛而谈
           - 可以建议：继续深化某个意象、转换视角、情感转折、留白收尾等
        
        **输出格式要求**：
        - 不要用 markdown 格式（不要用**加粗**、不要用•项目符号、不要用###标题）
        - 用换行分段，但不要用符号
        - 语气专业但友好，像一位经验丰富的创作导师
        - 总字数控制在200-300字
        - 结构：先肯定亮点 → 指出问题 → 给出续写建议
        
        **诗歌信息**：
        \(title.isEmpty ? "（无标题）" : "标题：《\(title)》")
        
        **已写内容**（共\(lines.count)行）：
        \(lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        **输出示例风格**（纯文字，无格式）：
        
        你想表达的是...（理解意图）
        
        用词方面，"XX"这个词很好，因为...；但"XX"可以改进，因为...
        
        意象上，你用了...，整体是统一的/有跳跃。建议...
        
        语言上，第X行出现了解释性句式/抽象词，建议改为更具体的表达。
        
        结构上，第X行相对较弱，因为...，可以考虑...
        
        续写建议：一是...；二是...；三是...
        """
        
        return try await callAI(
            prompt: prompt,
            systemMessage: "你是一位专业的现代诗创作导师，擅长深度分析诗歌创作，给出具体、可操作的改进建议。你既能看到作品的闪光点，也能犀利地指出问题，帮助创作者真正提升。你说话专业但友好，不用 markdown 格式，就是清晰的文字分析。",
            temperature: 0.7,
            maxTokens: 600
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

