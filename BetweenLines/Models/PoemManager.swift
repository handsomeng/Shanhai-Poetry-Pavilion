//
//  PoemManager.swift
//  山海诗馆
//
//  诗歌管理器：负责诗歌的存储、读取、管理
//

import Foundation
import Combine

/// 发布诗歌错误类型
enum PoemPublishError: LocalizedError {
    case similarContentExists(title: String)
    
    var errorDescription: String? {
        switch self {
        case .similarContentExists(let title):
            return "已发布过相似内容：《\(title)》"
        }
    }
}

/// 诗歌管理器（单例模式）
class PoemManager: ObservableObject {
    
    static let shared = PoemManager()
    
    // MARK: - Published Properties
    
    /// 所有诗歌（包括已发布和草稿）
    @Published private(set) var allPoems: [Poem] = []
    
    /// 当前用户的笔名
    @Published var currentUserName: String = ""
    
    // MARK: - 私有属性
    
    /// UserDefaults 存储键
    private let poemsKey = "saved_poems"
    private let publicPoemsKey = "public_poems"
    
    /// 用于监听笔名变化
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    private init() {
        loadPoems()
        loadCurrentUserName()
        loadPublicPoems()
        observePenNameChanges()
    }
    
    // MARK: - 计算属性（新逻辑）
    
    /// 我的诗集（已保存到本地的诗歌）
    var myCollection: [Poem] {
        allPoems.filter { $0.inMyCollection && $0.authorName == currentUserName }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// 我的草稿（未保存的诗歌，兼容旧逻辑）
    var myDrafts: [Poem] {
        allPoems.filter { !$0.inMyCollection && !$0.inSquare && $0.authorName == currentUserName }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// 我发布到广场的诗歌（引用列表）
    var myPublishedToSquare: [Poem] {
        allPoems.filter { $0.inSquare && $0.authorName == currentUserName }
            .sorted { $0.squarePublishedAt ?? $0.createdAt > $1.squarePublishedAt ?? $1.createdAt }
    }
    
    /// 广场诗歌（所有在广场上的诗歌）
    var explorePoems: [Poem] {
        allPoems.filter { $0.inSquare }
            .sorted { $0.squarePublishedAt ?? $0.createdAt > $1.squarePublishedAt ?? $1.createdAt }
    }
    
    /// 热门诗歌（按广场点赞数排序）
    var popularPoems: [Poem] {
        allPoems.filter { $0.inSquare }
            .sorted { $0.squareLikeCount > $1.squareLikeCount }
    }
    
    // MARK: - 兼容旧逻辑的计算属性（废弃）
    
    /// 我的已发布诗歌（废弃，改用 myCollection）
    @available(*, deprecated, message: "Use myCollection instead")
    var myPublishedPoems: [Poem] {
        myCollection
    }
    
    // MARK: - CRUD 操作
    
    /// 创建新诗歌（草稿）
    func createDraft(title: String, content: String, tags: [String] = [], writingMode: WritingMode = .direct, referencePoem: String? = nil) -> Poem {
        let poem = Poem(
            title: title,
            content: content,
            authorName: currentUserName,
            tags: tags,
            writingMode: writingMode,
            referencePoem: referencePoem,
            inMyCollection: false,
            inSquare: false
        )
        allPoems.append(poem)
        savePoems()
        return poem
    }
    
    /// 保存诗歌到【我的诗集】
    /// - Returns: 是否成功保存（false表示重复）
    @discardableResult
    func saveToCollection(_ poem: Poem) -> Bool {
        // 检查是否已存在相同内容的诗歌（防止重复保存）
        let isDuplicate = allPoems.contains { existingPoem in
            existingPoem.id != poem.id && // 不是同一首诗
            existingPoem.title == poem.title && // 标题相同
            existingPoem.content == poem.content && // 内容相同
            existingPoem.inMyCollection && // 已在诗集中
            existingPoem.authorName == currentUserName // 同一作者
        }
        
        if isDuplicate {
            print("⚠️ [PoemManager] 检测到重复诗歌，已跳过保存")
            return false
        }
        
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = poem
            updatedPoem.inMyCollection = true
            updatedPoem.updatedAt = Date()
            allPoems[index] = updatedPoem
            savePoems()
        } else {
            // 新诗歌
            var newPoem = poem
            newPoem.inMyCollection = true
            newPoem.updatedAt = Date()
            allPoems.append(newPoem)
            savePoems()
        }
        return true
    }
    
    /// 保存诗歌（通用方法，更新现有诗歌）
    func savePoem(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = poem
            updatedPoem.updatedAt = Date()
            allPoems[index] = updatedPoem
            savePoems()
        }
    }
    
    /// 发布诗歌到广场（新逻辑）
    /// 创建一个新的副本发布到广场，诗集和广场互不影响
    func publishToSquare(_ poem: Poem) throws {
        // 检查相似度
        if let similarPoem = try checkSimilarity(for: poem) {
            throw PoemPublishError.similarContentExists(title: similarPoem.title)
        }
        
        // 创建广场上的新副本（新的 ID）
        let squareId = UUID().uuidString
        let squareCopy = Poem(
            id: UUID().uuidString,  // 新的 ID，与诗集中的独立
            title: poem.title,
            content: poem.content,
            authorName: poem.authorName,
            createdAt: poem.createdAt,
            updatedAt: Date(),
            tags: poem.tags,
            writingMode: poem.writingMode,
            referencePoem: poem.referencePoem,
            aiComment: poem.aiComment,
            inMyCollection: false,   // 广场副本不在诗集中
            inSquare: true,          // 在广场中
            squareId: squareId,
            squarePublishedAt: Date(),
            squareLikeCount: 0
        )
        
        // 添加广场副本
        allPoems.append(squareCopy)
        
        // 更新诗集中的原诗歌，记录它的 squareId（用于关联）
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedOriginal = allPoems[index]
            updatedOriginal.squareId = squareId  // 记录广场 ID
            updatedOriginal.squarePublishedAt = Date()
            allPoems[index] = updatedOriginal
        }
        
        savePoems()
    }
    
    /// 从广场删除
    func removeFromSquare(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.inSquare = false
            updatedPoem.squareId = nil
            
            // 如果也不在诗集里，就彻底删除
            if !updatedPoem.inMyCollection {
                allPoems.remove(at: index)
            } else {
                allPoems[index] = updatedPoem
            }
            savePoems()
        }
    }
    
    /// 从诗集删除
    func removeFromCollection(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.inMyCollection = false
            
            // 如果也不在广场上，就彻底删除
            if !updatedPoem.inSquare {
                allPoems.remove(at: index)
            } else {
                allPoems[index] = updatedPoem
            }
            savePoems()
        }
    }
    
    /// 删除诗歌（彻底删除）
    func deletePoem(_ poem: Poem) {
        allPoems.removeAll { $0.id == poem.id }
        savePoems()
    }
    
    /// 批量删除诗歌
    func deletePoems(_ poems: [Poem]) {
        let idsToDelete = Set(poems.map { $0.id })
        allPoems.removeAll { idsToDelete.contains($0.id) }
        savePoems()
    }
    
    /// 点赞/取消点赞（广场诗歌）
    func toggleLike(for poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.isLiked.toggle()
            updatedPoem.squareLikeCount += updatedPoem.isLiked ? 1 : -1
            allPoems[index] = updatedPoem
            savePoems()
        }
    }
    
    /// 添加 AI 点评
    func addAIComment(to poem: Poem, comment: String) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.aiComment = comment
            allPoems[index] = updatedPoem
            savePoems()
        }
    }
    
    /// 根据 ID 获取诗歌
    func getPoem(by id: String) -> Poem? {
        allPoems.first { $0.id == id }
    }
    
    // MARK: - 本地存储
    
    /// 保存到本地
    private func savePoems() {
        // 只保存当前用户的诗歌
        let myPoems = allPoems.filter { $0.authorName == currentUserName }
        
        if let encoded = try? JSONEncoder().encode(myPoems) {
            UserDefaults.standard.set(encoded, forKey: poemsKey)
        }
    }
    
    /// 从本地加载
    private func loadPoems() {
        if let data = UserDefaults.standard.data(forKey: poemsKey),
           let decoded = try? JSONDecoder().decode([Poem].self, from: data) {
            allPoems = decoded
        }
    }
    
    /// 加载当前用户名
    private func loadCurrentUserName() {
        currentUserName = UserDefaults.standard.string(forKey: UserDefaultsKeys.penName) ?? "诗人"
    }
    
    /// 监听笔名变化
    private func observePenNameChanges() {
        // 监听UserDefaults中penName的变化
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let newPenName = UserDefaults.standard.string(forKey: UserDefaultsKeys.penName) ?? "诗人"
                
                // 如果笔名发生变化，同步更新所有诗歌的authorName
                if newPenName != self.currentUserName {
                    let oldPenName = self.currentUserName
                    print("📝 [PoemManager] 检测到笔名变化: \(oldPenName) → \(newPenName)")
                    self.updateAuthorName(from: oldPenName, to: newPenName)
                    self.currentUserName = newPenName
                }
            }
            .store(in: &cancellables)
    }
    
    /// 更新所有诗歌的作者名
    private func updateAuthorName(from oldName: String, to newName: String) {
        var updated = false
        
        for i in 0..<allPoems.count {
            if allPoems[i].authorName == oldName {
                allPoems[i].authorName = newName
                updated = true
            }
        }
        
        if updated {
            savePoems()
            print("✅ [PoemManager] 已更新 \(allPoems.count) 首诗歌的作者名")
        }
    }
    
    /// 加载公共诗歌（示例数据）
    private func loadPublicPoems() {
        // 每次启动都加载示例诗歌到内存（不持久化，避免丢失）
        // 示例诗歌的authorName与当前用户不同，不会被savePoems()保存
        
        // 检查是否已有示例诗歌（避免重复添加）
        let hasExamples = allPoems.contains { poem in
            Poem.examples.contains { example in
                example.id == poem.id
            }
        }
        
        if !hasExamples {
            allPoems.append(contentsOf: Poem.examples)
            print("✅ [PoemManager] 已加载 \(Poem.examples.count) 首示例诗歌")
        }
    }
    
    // MARK: - 搜索和筛选
    
    /// 按标签搜索（广场）
    func searchByTag(_ tag: String) -> [Poem] {
        allPoems.filter { $0.inSquare && $0.tags.contains(tag) }
    }
    
    /// 按关键词搜索（广场）
    func search(keyword: String) -> [Poem] {
        let lowercased = keyword.lowercased()
        return allPoems.filter { poem in
            poem.inSquare && (
                poem.title.lowercased().contains(lowercased) ||
                poem.content.lowercased().contains(lowercased) ||
                poem.authorName.lowercased().contains(lowercased)
            )
        }
    }
    
    /// 按创作模式筛选（广场）
    func filterByMode(_ mode: WritingMode) -> [Poem] {
        allPoems.filter { $0.inSquare && $0.writingMode == mode }
    }
    
    // MARK: - 相似度检测
    
    /// 检查是否已发布相似内容
    private func checkSimilarity(for poem: Poem) throws -> Poem? {
        // 获取我已发布到广场的诗歌
        let mySquarePoems = allPoems.filter {
            $0.inSquare && $0.authorName == currentUserName && $0.id != poem.id
        }
        
        for existingPoem in mySquarePoems {
            // 检查标题是否相同
            if existingPoem.title == poem.title && !poem.title.isEmpty {
                return existingPoem
            }
            
            // 检查内容相似度
            let similarity = calculateSimilarity(existingPoem.content, poem.content)
            if similarity > 0.7 {
                return existingPoem
            }
        }
        
        return nil
    }
    
    /// 计算两个字符串的相似度（简单实现：共同字符比例）
    private func calculateSimilarity(_ str1: String, _ str2: String) -> Double {
        let set1 = Set(str1)
        let set2 = Set(str2)
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        
        guard !union.isEmpty else { return 0 }
        return Double(intersection.count) / Double(union.count)
    }
    
    // MARK: - 统计数据
    
    /// 我的统计（新逻辑）
    var myStats: (totalPoems: Int, totalDrafts: Int, totalLikes: Int) {
        let collection = myCollection.count
        let drafts = myDrafts.count
        let likes = myPublishedToSquare.reduce(0) { $0 + $1.squareLikeCount }
        return (collection, drafts, likes)
    }
    
    // MARK: - 诗人称号
    
    /// 当前诗人称号
    var currentPoetTitle: PoetTitle {
        let totalCount = myCollection.count
        return PoetTitle.title(forPoemCount: totalCount)
    }
    
    /// 所有称号的解锁状态
    var titleAchievements: [TitleAchievement] {
        let totalCount = myCollection.count
        return PoetTitle.allCases.map { title in
            TitleAchievement(
                title: title,
                isUnlocked: totalCount >= title.requiredCount,
                currentCount: totalCount
            )
        }
    }
    
    /// 距离下一称号还需多少首
    var poemsToNextTitle: Int? {
        let totalCount = myCollection.count
        return currentPoetTitle.poemsToNextTitle(currentCount: totalCount)
    }
    
    /// 到下一称号的进度（0.0 - 1.0）
    var progressToNextTitle: Double {
        let totalCount = myCollection.count
        return currentPoetTitle.progress(currentCount: totalCount)
    }
    
    // MARK: - 数据管理
    
    /// 删除所有诗歌（用于重置数据）
    func deleteAll() {
        allPoems.removeAll()
        savePoems()
        // 重新加载示例诗歌
        loadPublicPoems()
    }
}

