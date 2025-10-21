//
//  LearningContent.swift
//  BetweenLines - 字里行间
//
//  学习内容数据模型：大主题 → 小主题 → 文章内容
//

import Foundation

/// 大主题（如：现代诗入门、诗歌技巧等）
struct LearningTopic: Identifiable {
    let id: String
    let title: String              // 大主题标题
    let description: String        // 大主题描述
    let icon: String               // SF Symbol 图标名
    let articles: [LearningArticle] // 该主题下的文章列表
    
    /// 预计学习时间（分钟）
    var totalReadingTime: Int {
        articles.reduce(0) { $0 + $1.readingTimeMinutes }
    }
    
    /// 文章数量
    var articleCount: Int {
        articles.count
    }
}

/// 小主题/学习文章
struct LearningArticle: Identifiable {
    let id: String
    let topicId: String            // 所属大主题 ID
    let title: String              // 文章标题
    let summary: String            // 摘要（列表显示）
    let content: String            // Markdown 内容
    let readingTimeMinutes: Int    // 预计阅读时间
    let order: Int                 // 在主题中的排序
}

// MARK: - 学习内容管理器

/// 学习内容管理器：加载和管理所有学习资源
class LearningContentManager {
    
    static let shared = LearningContentManager()
    
    private init() {}
    
    /// 获取所有大主题
    func getAllTopics() -> [LearningTopic] {
        return [
            // 主题 1：现代诗入门
            LearningTopic(
                id: "topic_basics",
                title: "现代诗入门",
                description: "从零开始了解现代诗，建立基础认知",
                icon: "book.fill",
                articles: getBasicsArticles()
            ),
            
            // 主题 2：诗歌语言
            LearningTopic(
                id: "topic_language",
                title: "诗歌语言",
                description: "学习现代诗的核心表达技巧",
                icon: "character.bubble.fill",
                articles: getLanguageArticles()
            ),
            
            // 主题 3：节奏与结构
            LearningTopic(
                id: "topic_structure",
                title: "节奏与结构",
                description: "掌握诗歌的形式与韵律",
                icon: "waveform",
                articles: getStructureArticles()
            ),
            
            // 主题 4：情感表达
            LearningTopic(
                id: "topic_emotion",
                title: "情感表达",
                description: "如何在诗中传递真实的情感",
                icon: "heart.text.square.fill",
                articles: getEmotionArticles()
            ),
            
            // 主题 5：经典赏析
            LearningTopic(
                id: "topic_classics",
                title: "经典赏析",
                description: "解读名家名作，学习创作精髓",
                icon: "star.fill",
                articles: getClassicsArticles()
            ),
            
            // 主题 6：实践指南
            LearningTopic(
                id: "topic_practice",
                title: "实践指南",
                description: "从开始到持续创作的实用建议",
                icon: "pencil.and.outline",
                articles: getPracticeArticles()
            )
        ]
    }
    
    /// 根据主题 ID 获取主题
    func getTopic(by id: String) -> LearningTopic? {
        getAllTopics().first { $0.id == id }
    }
    
    /// 根据文章 ID 获取文章
    func getArticle(by id: String) -> LearningArticle? {
        getAllTopics()
            .flatMap { $0.articles }
            .first { $0.id == id }
    }
}

// MARK: - 主题 1：现代诗入门

extension LearningContentManager {
    
    private func getBasicsArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "basics_001",
                topicId: "topic_basics",
                title: "什么是现代诗",
                summary: "了解现代诗的定义、起源和基本特征",
                content: """
                # 什么是现代诗
                
                ## 定义
                
                现代诗，又称**新诗**、**白话诗**，是相对于古典诗词而言的一种诗歌形式。它诞生于五四运动时期（1919年前后），使用现代汉语（白话文）创作，不受传统格律限制。
                
                ## 核心特点
                
                ### 1. 语言自由
                - 使用日常口语和白话文
                - 不需要遵守平仄、押韵等格律
                - 可以使用现代词汇和外来语
                
                ### 2. 形式多样
                - 行数、节数不受限制
                - 句子长短自由安排
                - 分节、分行全凭创作需要
                
                ### 3. 表达直接
                - 直抒胸臆，表达真实感受
                - 不需要用典故和古语
                - 关注当下的生活和情感
                
                ### 4. 意象现代
                - 使用现代生活的意象（城市、汽车、手机等）
                - 表达现代人的困惑和思考
                - 反映当代社会和文化
                
                ## 一个简单例子
                
                > 风吹过时，我们在说些什么  
                > 那些未完成的句子  
                > 被吹散在夜色里
                
                这就是现代诗：没有格律，使用日常语言，表达现代人的感受。
                
                ## 与古典诗词的区别
                
                | 特征 | 古典诗词 | 现代诗 |
                |------|---------|--------|
                | 语言 | 文言文 | 白话文 |
                | 格律 | 严格（平仄、押韵） | 自由 |
                | 句式 | 固定（五言、七言等） | 灵活 |
                | 意象 | 传统（月、酒、柳等） | 现代 |
                
                ## 现代诗的价值
                
                现代诗让每个人都能用自己的语言写诗，表达独特的感受。它不是精英的游戏，而是属于每个人的表达方式。
                """,
                readingTimeMinutes: 5,
                order: 1
            ),
            
            LearningArticle(
                id: "basics_002",
                topicId: "topic_basics",
                title: "为什么要写现代诗",
                summary: "探索写诗的意义和价值",
                content: """
                # 为什么要写现代诗
                
                ## 写诗不是为了成为诗人
                
                很多人觉得写诗是"文艺青年"或"诗人"的专利，普通人不需要也不会写诗。但事实上，**写诗是一种生活方式**，是一种观察世界和表达自我的方式。
                
                ## 写诗的五个理由
                
                ### 1. 捕捉稍纵即逝的感受
                
                生活中有很多微妙的感受，一闪而过，难以用日常语言描述。诗歌可以帮你捕捉和保存这些瞬间。
                
                比如，当你看到落日时的某种说不清的情绪，用诗歌记录：
                
                > 夕阳把影子拉得很长  
                > 像是在跟一天告别
                
                ### 2. 理解自己的情绪
                
                写诗的过程是一个自我探索的过程。当你试图用文字表达感受时，你会更清楚地认识自己的情绪。
                
                ### 3. 发现生活的诗意
                
                写诗会让你用不同的眼光看世界。你会开始注意到那些被忽略的细节：
                - 清晨的第一缕阳光
                - 雨后的树叶
                - 陌生人的表情
                - 城市的声音
                
                ### 4. 连接他人
                
                当你写下真实的感受时，会发现有人与你产生共鸣。诗歌是心灵与心灵的对话，跨越时空的连接。
                
                ### 5. 让语言变得有力量
                
                诗歌教会你如何精炼地使用语言。一首好诗可以用几十个字传递复杂的情感，这种能力会延伸到日常表达中。
                
                ## 写诗不需要什么
                
                - ❌ 不需要文学学位
                - ❌ 不需要读过很多诗
                - ❌ 不需要"有才华"
                - ❌ 不需要等待灵感
                
                ## 你只需要
                
                - ✅ 真实的感受
                - ✅ 观察生活的眼睛
                - ✅ 愿意尝试的勇气
                - ✅ 持续练习的耐心
                
                ## 从今天开始
                
                写诗不是为了发表，不是为了给别人看，而是为了你自己。
                
                今天，试着写下一个你注意到的细节，或者一个让你停顿的瞬间。不用担心写得好不好，重要的是开始。
                """,
                readingTimeMinutes: 4,
                order: 2
            ),
            
            LearningArticle(
                id: "basics_003",
                topicId: "topic_basics",
                title: "现代诗的基本特点",
                summary: "掌握现代诗的核心要素",
                content: """
                # 现代诗的基本特点
                
                理解这些特点，会帮助你更好地阅读和创作现代诗。
                
                ## 1. 分行（最重要的形式特征）
                
                **分行是诗歌区别于散文的最重要标志。**
                
                同样的内容，分行方式不同，感觉完全不同：
                
                **版本A（散文化）**：
                > 风吹过时我们在说些什么那些未完成的句子被吹散在夜色里。
                
                **版本B（诗歌分行）**：
                > 风吹过时，我们在说些什么  
                > 那些未完成的句子  
                > 被吹散在夜色里
                
                分行创造了**停顿**和**节奏**，让读者有时间感受每一句话。
                
                ### 分行的作用
                - 创造节奏感
                - 强调重点词汇（行末的词会被强调）
                - 控制阅读速度
                - 营造情绪氛围
                
                ## 2. 意象（诗的核心）
                
                **意象 = 具体的形象 + 抽象的情感**
                
                好的诗歌不会直接说"我很孤独"，而是用具体的意象表达：
                
                > 一个人的咖啡馆  
                > 对面的椅子  
                > 空着
                
                ### 常见意象
                - **自然**：风、雨、树、月亮、海
                - **城市**：街道、窗、灯光、地铁
                - **日常**：咖啡、书、影子、镜子
                
                ## 3. 留白（不说透）
                
                **好的诗歌不会把话说满，而是留下想象空间。**
                
                对比：
                
                **说得太满**：
                > 我非常想念你  
                > 日日夜夜都在想  
                > 想得心都要碎了
                
                **留白的表达**：
                > 你的名字  
                > 在雨声里
                
                留白让读者自己完成诗歌，每个人都能有自己的理解。
                
                ## 4. 跳跃（不需要严密逻辑）
                
                诗歌可以跳跃，不需要像作文那样"承上启下"。
                
                例如：
                > 夜晚的城市  
                > 像一条巨大的鱼  
                >  
                > 母亲还在等我回家
                
                从"城市"跳到"母亲"，看似无关，但在情感上是连贯的。
                
                ## 5. 简洁（少即是多）
                
                诗歌追求语言的精炼。能用一个词说清的，不用两个。
                
                **冗长版**：
                > 当风吹过来的时候  
                > 我们正在说着一些话  
                > 但是那些话还没有说完  
                > 就被风吹散了
                
                **简洁版**：
                > 风吹过时  
                > 未完成的句子  
                > 散了
                
                ## 6. 现代感（当下的生活）
                
                现代诗关注现代人的生活和情感：
                - 城市的孤独
                - 快节奏的压力
                - 网络时代的连接与疏离
                - 环境的变化
                
                不要刻意使用古语或典故，用你自己的语言。
                
                ## 实践建议
                
                1. **多分行，少长句**：尝试每行不超过 15 个字
                2. **用意象，不直说**：把抽象情感转化为具体画面
                3. **留空白，不说满**：删掉解释性的话
                4. **敢跳跃，不啰嗦**：相信读者的理解力
                5. **写当下，不装古**：用你平时说话的语言
                
                ## 记住
                
                现代诗的本质是**真诚**和**简洁**。
                
                不是越复杂越好，不是越难懂越好。最好的诗是简单而有力量的。
                """,
                readingTimeMinutes: 6,
                order: 3
            ),
            
            LearningArticle(
                id: "basics_004",
                topicId: "topic_basics",
                title: "现代诗简史",
                summary: "快速了解中国现代诗的发展脉络",
                content: """
                # 现代诗简史
                
                了解现代诗的发展历程，帮助你理解不同时期诗歌的特点。
                
                ## 起源：五四时期（1919-1930）
                
                ### 开创者：胡适
                
                1920年，胡适出版《尝试集》，这是第一部白话新诗集，标志着现代诗的诞生。
                
                代表作《两只蝴蝶》（节选）：
                > 两只黄蝴蝶，双双飞上天。  
                > 不知为什么，一个忽飞还。
                
                特点：简单、口语化，像儿歌。
                
                ### 浪漫派：徐志摩
                
                代表作《再别康桥》（1928）是最广为传诵的现代诗之一。
                
                特点：优美、抒情、音乐性强。
                
                ## 发展：30-40年代
                
                ### 现代派：戴望舒
                
                代表作《雨巷》（1928），开创了象征主义风格。
                
                > 撑着油纸伞，独自  
                > 彷徨在悠长、悠长  
                > 又寂寥的雨巷
                
                特点：注重意象、象征、音乐性。
                
                ## 新时期：朦胧诗（1970-1980年代）
                
                文革结束后，一批年轻诗人用隐晦、象征的方式表达对现实的思考。
                
                ### 北岛
                
                代表作《回答》（1976），那句"卑鄙是卑鄙者的通行证，高尚是高尚者的墓志铭"成为时代之声。
                
                ### 顾城
                
                代表作《一代人》（1979），仅两行：
                > 黑夜给了我黑色的眼睛  
                > 我却用它寻找光明
                
                ### 舒婷
                
                代表作《致橡树》，表达了新时代女性的独立意识。
                
                **朦胧诗特点**：
                - 意象丰富、含蓄
                - 表达个人感受和思考
                - 不直白说教
                
                ## 第三代：口语诗（1980年代中后期）
                
                反对朦胧诗的"晦涩"，追求日常、口语、平民化。
                
                ### 于坚
                
                代表作《尚义街六号》，用极其日常的语言写诗。
                
                特点：像说话一样，接地气。
                
                ## 90年代至今：多元化
                
                ### 海子（1964-1989）
                
                虽然在 80 年代创作，但影响在 90 年代后才广泛显现。
                
                代表作《面朝大海，春暖花开》（1989），成为最受欢迎的现代诗之一。
                
                特点：纯净、简单、充满理想主义。
                
                ### 余秀华（1976-）
                
                2014 年因《穿过大半个中国去睡你》在网络走红，掀起诗歌热潮。
                
                特点：直接、粗粝、真实。
                
                ### 当代：百花齐放
                
                今天的诗歌没有统一风格，各种流派并存：
                - 口语诗
                - 知识分子写作
                - 下半身写作
                - 网络诗歌
                - 微信诗歌
                
                **每个人都可以找到适合自己的表达方式。**
                
                ## 你处在什么时代
                
                你现在创作，就是在参与当代诗歌的书写。
                
                不需要刻意模仿某个流派，找到自己真实的声音最重要。
                
                ## 推荐阅读
                
                如果你想深入了解，可以读：
                - 《新诗十九首》（胡适等）
                - 《北岛诗选》
                - 《海子诗全集》
                - 《余秀华诗选》
                
                但记住：**读诗是为了启发，不是为了模仿。**
                """,
                readingTimeMinutes: 7,
                order: 4
            )
        ]
    }
}

// MARK: - 主题 2：诗歌语言

extension LearningContentManager {
    
    private func getLanguageArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "language_001",
                topicId: "topic_language",
                title: "意象的运用",
                summary: "学会用具体的画面传递抽象的情感",
                content: "（内容较长，此处省略）",
                readingTimeMinutes: 8,
                order: 1
            )
        ]
    }
}

// MARK: - 其他主题的文章（示例框架，内容待补充）

extension LearningContentManager {
    
    private func getStructureArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "structure_001",
                topicId: "topic_structure",
                title: "分行的技巧",
                summary: "掌握诗歌分行的节奏与呼吸",
                content: "（内容待补充）",
                readingTimeMinutes: 6,
                order: 1
            )
        ]
    }
    
    private func getEmotionArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "emotion_001",
                topicId: "topic_emotion",
                title: "如何表达情绪",
                summary: "用画面而非词汇传递情感",
                content: "（内容待补充）",
                readingTimeMinutes: 7,
                order: 1
            )
        ]
    }
    
    private func getClassicsArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "classics_001",
                topicId: "topic_classics",
                title: "海子《面朝大海，春暖花开》",
                summary: "解读这首最受欢迎的现代诗",
                content: "（内容待补充）",
                readingTimeMinutes: 10,
                order: 1
            )
        ]
    }
    
    private func getPracticeArticles() -> [LearningArticle] {
        return [
            LearningArticle(
                id: "practice_001",
                topicId: "topic_practice",
                title: "如何开始第一首诗",
                summary: "零基础创作指南",
                content: "（内容待补充）",
                readingTimeMinutes: 8,
                order: 1
            )
        ]
    }
}

