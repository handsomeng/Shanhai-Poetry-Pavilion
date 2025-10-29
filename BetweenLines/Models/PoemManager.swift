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

/// iCloud 同步状态
enum iCloudSyncStatus {
    case idle           // 空闲
    case syncing        // 同步中
    case synced         // 已同步
    case failed(String) // 同步失败
    
    var description: String {
        switch self {
        case .idle: return "待同步"
        case .syncing: return "同步中..."
        case .synced: return "已同步"
        case .failed(let error): return "同步失败: \(error)"
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
    
    /// iCloud 同步状态
    @Published private(set) var syncStatus: iCloudSyncStatus = .idle
    
    // MARK: - 私有属性
    
    /// 用户身份服务
    private let identityService = UserIdentityService()
    
    /// 当前用户的 ID（设备唯一标识）
    private var currentUserId: String {
        return identityService.userId
    }
    
    /// UserDefaults 存储键（基于设备 userId）
    private var poemsKey: String {
        return "saved_poems_\(currentUserId)"
    }
    
    /// iCloud 存储键（基于设备 userId，自动同步）
    private var iCloudPoemsKey: String {
        return "icloud_poems_\(currentUserId)"
    }
    
    private let publicPoemsKey = "public_poems"
    
    /// 用于监听笔名变化和账号变化
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    private init() {
        loadPoems()
        loadCurrentUserName()
        // loadPublicPoems() // V2-lite: 移除示例诗歌，让用户从空白开始
        observePenNameChanges()
        observeiCloudChanges()
        // observeAuthChanges() // 已移除登录系统，不需要监听账号变化
    }
    
    // MARK: - 计算属性（新逻辑）
    
    /// 我的诗集（已保存到本地的诗歌）
    var myCollection: [Poem] {
        let filtered = allPoems.filter { poem in
            guard poem.inMyCollection else { return false }
            
            // 优先使用 userId 过滤
            if let poemUserId = poem.userId {
                let match = (poemUserId == currentUserId)
                if !match {
                    print("   [myCollection] 跳过诗歌 '\(poem.title)' (userId不匹配: \(poemUserId) != \(currentUserId))")
                }
                return match
            }
            
            // 兼容旧数据（没有 userId 的诗歌）
            let match = (poem.authorName == currentUserName)
            if !match {
                print("   [myCollection] 跳过诗歌 '\(poem.title)' (authorName不匹配: \(poem.authorName) != \(currentUserName))")
            }
            return match
        }
        .sorted { $0.updatedAt > $1.updatedAt }
        
        print("📚 [myCollection] 诗集数量: \(filtered.count) (allPoems: \(allPoems.count))")
        if !filtered.isEmpty {
            print("   诗歌列表:")
            for (index, poem) in filtered.enumerated() {
                print("   \(index + 1). \(poem.title) (userId: \(poem.userId ?? "nil"))")
            }
        }
        
        return filtered
    }
    
    /// 我的草稿（未保存的诗歌，兼容旧逻辑）
    var myDrafts: [Poem] {
        allPoems.filter { poem in
            guard !poem.inMyCollection && !poem.inSquare else { return false }
            
            // 优先使用 userId 过滤
            if let poemUserId = poem.userId {
                return poemUserId == currentUserId
            }
            
            // 兼容旧数据
            return poem.authorName == currentUserName
        }
        .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// 我发布到广场的诗歌（引用列表）
    var myPublishedToSquare: [Poem] {
        allPoems.filter { poem in
            guard poem.inSquare else { return false }
            
            // 优先使用 userId 过滤
            if let poemUserId = poem.userId {
                return poemUserId == currentUserId
            }
            
            // 兼容旧数据
            return poem.authorName == currentUserName
        }
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
            userId: currentUserId, // 设置 userId
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
        print("📝 [saveToCollection] 开始保存诗歌到诗集")
        print("   • 诗歌标题: \(poem.title)")
        print("   • 诗歌ID: \(poem.id)")
        print("   • 诗歌userId: \(poem.userId ?? "nil")")
        print("   • currentUserId: \(currentUserId)")
        print("   • 当前allPoems数量: \(allPoems.count)")
        
        // ⚠️ 关键修复：如果诗歌没有 userId，自动设置为当前用户 ID
        var poemToSave = poem
        if poemToSave.userId == nil {
            poemToSave.userId = currentUserId
            print("🔧 [saveToCollection] 自动设置 userId: \(currentUserId)")
        }
        
        // 检查是否已存在相同内容的诗歌（防止重复保存）
        let isDuplicate = allPoems.contains { existingPoem in
            guard existingPoem.id != poemToSave.id else { return false } // 不是同一首诗
            guard existingPoem.title == poemToSave.title else { return false } // 标题相同
            guard existingPoem.content == poemToSave.content else { return false } // 内容相同
            guard existingPoem.inMyCollection else { return false } // 已在诗集中
            
            // 使用 userId 判断是否同一作者（优先级更高）
            if let existingUserId = existingPoem.userId, let newUserId = poemToSave.userId {
                return existingUserId == newUserId
            }
            
            // 兼容旧数据：使用 authorName
            return existingPoem.authorName == poemToSave.authorName
        }
        
        if isDuplicate {
            print("⚠️ [PoemManager] 检测到重复诗歌！")
            print("   • 标题: \(poemToSave.title)")
            print("   • 内容: \(poemToSave.content.prefix(50))...")
            print("   • 已跳过保存")
            return false
        }
        
        if let index = allPoems.firstIndex(where: { $0.id == poemToSave.id }) {
            print("✅ [saveToCollection] 找到现有诗歌，更新中...")
            var updatedPoem = poemToSave
            updatedPoem.inMyCollection = true
            updatedPoem.updatedAt = Date()
            allPoems[index] = updatedPoem
            print("   • 更新后的 userId: \(updatedPoem.userId ?? "nil")")
            print("   • 更新后allPoems数量: \(allPoems.count)")
            savePoems()
        } else {
            print("✅ [saveToCollection] 新诗歌，添加到 allPoems...")
            // 新诗歌
            var newPoem = poemToSave
            newPoem.inMyCollection = true
            newPoem.updatedAt = Date()
            allPoems.append(newPoem)
            print("   • 新诗歌的 userId: \(newPoem.userId ?? "nil")")
            print("   • 添加后allPoems数量: \(allPoems.count)")
            savePoems()
        }
        return true
    }
    
    /// 保存诗歌（通用方法，更新现有诗歌或添加新诗歌）
    func savePoem(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            // 更新现有诗歌
            var updatedPoem = poem
            updatedPoem.updatedAt = Date()
            allPoems[index] = updatedPoem
            savePoems()
        } else {
            // 添加新诗歌
            var newPoem = poem
            newPoem.updatedAt = Date()
            allPoems.append(newPoem)
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
    
    // MARK: - 本地存储 + iCloud 同步
    
    /// 保存到本地和 iCloud
    private func savePoems() {
        print("💾 [PoemManager] savePoems() 被调用")
        print("   • allPoems 数量: \(allPoems.count)")
        print("   • currentUserId: \(currentUserId)")
        
        // 只保存当前用户的诗歌（使用 userId 严格隔离）
        let myPoems = allPoems.filter { poem in
            // V2-lite: 已移除示例诗歌，无需排除
            
            // 优先使用 userId 过滤（新数据）
            if let poemUserId = poem.userId {
                let match = (poemUserId == currentUserId)
                if !match {
                    print("   • 跳过诗歌 '\(poem.title)' (userId: \(poemUserId) != currentUserId: \(currentUserId))")
                }
                return match
            }
            
            // 兼容旧数据（没有 userId 的诗歌，使用 authorName）
            print("   • 包含旧诗歌 '\(poem.title)' (无userId，用authorName)")
            return poem.authorName == currentUserName
        }
        
        print("   • 过滤后待保存诗歌数量: \(myPoems.count)")
        
        guard let encoded = try? JSONEncoder().encode(myPoems) else {
            print("❌ [PoemManager] 诗歌编码失败")
            DispatchQueue.main.async { [weak self] in
                self?.syncStatus = .failed("编码失败")
            }
            return
        }
        
        // 1. 保存到本地 UserDefaults（快速访问）
        let localKey = poemsKey
        UserDefaults.standard.set(encoded, forKey: localKey)
        print("💾 [PoemManager] 已保存到本地: \(localKey) (\(myPoems.count) 首诗)")
        
        // 2. 同步到 iCloud（自动同步）
        DispatchQueue.main.async { [weak self] in
            self?.syncStatus = .syncing
        }
        
        let iCloudStore = NSUbiquitousKeyValueStore.default
        iCloudStore.set(encoded, forKey: iCloudPoemsKey)
        
        // 立即同步到 iCloud
        let synced = iCloudStore.synchronize()
        
        DispatchQueue.main.async { [weak self] in
            if synced {
                self?.syncStatus = .synced
                print("☁️ [PoemManager] 已同步到 iCloud: \(self?.iCloudPoemsKey ?? "") (\(myPoems.count) 首诗)")
            } else {
                self?.syncStatus = .idle
                print("⚠️ [PoemManager] iCloud 同步可能延迟")
            }
        }
    }
    
    /// 从 iCloud 或本地加载（优先 iCloud）
    private func loadPoems() {
        let localKey = poemsKey
        let cloudKey = iCloudPoemsKey
        let iCloudStore = NSUbiquitousKeyValueStore.default
        
        // 1. 优先从 iCloud 加载（最新数据）
        if let iCloudData = iCloudStore.data(forKey: cloudKey),
           let decoded = try? JSONDecoder().decode([Poem].self, from: iCloudData) {
            allPoems = decoded
            print("☁️ [PoemManager] 已从 iCloud 加载: \(cloudKey) (\(decoded.count) 首诗)")
            
            // 同步到本地（提高下次加载速度）
            UserDefaults.standard.set(iCloudData, forKey: localKey)
            
            // 迁移旧数据
            migrateOldPoems()
            return
        }
        
        // 2. 如果 iCloud 无数据，回退到本地
        if let localData = UserDefaults.standard.data(forKey: localKey),
           let decoded = try? JSONDecoder().decode([Poem].self, from: localData) {
            allPoems = decoded
            print("💾 [PoemManager] 已从本地加载: \(localKey) (\(decoded.count) 首诗)")
            
            // 迁移旧数据
            migrateOldPoems()
            
            // 上传到 iCloud（首次同步）
            iCloudStore.set(localData, forKey: cloudKey)
            iCloudStore.synchronize()
            print("☁️ [PoemManager] 已将本地数据上传到 iCloud: \(cloudKey)")
            return
        }
        
        print("📝 [PoemManager] 无数据，全新开始 (key: \(localKey))")
    }
    
    /// 迁移旧数据：为没有 userId 的诗歌设置 userId
    private func migrateOldPoems() {
        var needsMigration = false
        let userId = currentUserId
        
        for i in 0..<allPoems.count {
            // V2-lite: 已移除示例诗歌，无需跳过
            
            // 如果诗歌没有 userId，设置为当前用户的 ID
            if allPoems[i].userId == nil {
                allPoems[i].userId = userId
                needsMigration = true
                print("🔄 [PoemManager] 为诗歌 \(allPoems[i].title) 设置 userId: \(userId)")
            }
        }
        
        if needsMigration {
            print("✅ [PoemManager] 已迁移 \(allPoems.filter { $0.userId != nil }.count) 首旧诗歌，设置 userId")
            // 注意：不在这里调用 savePoems()，避免在 reloadData() 过程中保存
            // 数据会在下次 savePoems() 时自动保存
        }
    }
    
    /// 加载当前用户名
    private func loadCurrentUserName() {
        currentUserName = UserDefaults.standard.string(forKey: UserDefaultsKeys.penName) ?? "山海诗人"
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
    
    /// 监听 iCloud 变化（其他设备的更新）
    private func observeiCloudChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleiCloudStoreChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        
        print("☁️ [PoemManager] 已启动 iCloud 变化监听")
    }
    
    /// 处理 iCloud 数据变化
    @objc private func handleiCloudStoreChange(notification: Notification) {
        print("☁️ [PoemManager] 检测到 iCloud 数据变化")
        
        guard let userInfo = notification.userInfo,
              let changeReason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }
        
        // 变化原因
        let reason: String
        switch changeReason {
        case NSUbiquitousKeyValueStoreServerChange:
            reason = "服务器同步"
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            reason = "初始同步"
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            reason = "存储配额超限"
            print("⚠️ [PoemManager] iCloud 存储空间不足")
        case NSUbiquitousKeyValueStoreAccountChange:
            reason = "账号变更"
        default:
            reason = "未知原因"
        }
        
        print("☁️ [PoemManager] 变化原因: \(reason)")
        
        // 重新加载数据（使用动态 key）
        let cloudKey = iCloudPoemsKey
        let localKey = poemsKey
        let iCloudStore = NSUbiquitousKeyValueStore.default
        if let iCloudData = iCloudStore.data(forKey: cloudKey),
           let decoded = try? JSONDecoder().decode([Poem].self, from: iCloudData) {
            
            // 更新数据
            DispatchQueue.main.async { [weak self] in
                self?.allPoems = decoded
                print("✅ [PoemManager] 已从 iCloud 更新: \(cloudKey) (\(decoded.count) 首诗)")
                
                // 同步到本地
                UserDefaults.standard.set(iCloudData, forKey: localKey)
            }
        }
    }
    
    /// 加载公共诗歌（示例数据）
    /// V2-lite: 已禁用，让用户从空白开始
    private func loadPublicPoems() {
        // V2-lite 版本：不加载示例诗歌
        // 用户登录后从空白开始，更有成就感
        
        // 旧逻辑（已禁用）：
        // let hasExamples = allPoems.contains { poem in
        //     Poem.examples.contains { example in
        //         example.id == poem.id
        //     }
        // }
        // 
        // if !hasExamples {
        //     allPoems.append(contentsOf: Poem.examples)
        //     print("✅ [PoemManager] 已加载 \(Poem.examples.count) 首示例诗歌")
        // }
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
        // loadPublicPoems() // V2-lite: 移除示例诗歌
    }
}

