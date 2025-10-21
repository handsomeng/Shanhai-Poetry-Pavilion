//
//  PoemManager.swift
//  山海诗馆
//
//  诗歌管理器：负责诗歌的存储、读取、管理
//

import Foundation
import Combine

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
    
    // MARK: - 初始化
    
    private init() {
        loadPoems()
        loadCurrentUserName()
        loadPublicPoems()
    }
    
    // MARK: - 计算属性
    
    /// 我的已发布诗歌
    var myPublishedPoems: [Poem] {
        allPoems.filter { $0.isPublished && $0.authorName == currentUserName }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 我的草稿
    var myDrafts: [Poem] {
        allPoems.filter { !$0.isPublished && $0.authorName == currentUserName }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// 我收藏的诗歌
    var myFavorites: [Poem] {
        allPoems.filter { $0.isFavorited }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 广场诗歌（所有已发布的诗歌）
    var explorePoems: [Poem] {
        allPoems.filter { $0.isPublished }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 热门诗歌（按点赞数排序）
    var popularPoems: [Poem] {
        allPoems.filter { $0.isPublished }
            .sorted { $0.likeCount > $1.likeCount }
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
            isPublished: false
        )
        allPoems.append(poem)
        savePoems()
        return poem
    }
    
    /// 保存诗歌（更新现有诗歌）
    func savePoem(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = poem
            updatedPoem.updatedAt = Date()
            allPoems[index] = updatedPoem
            savePoems()
        }
    }
    
    /// 发布诗歌
    func publishPoem(_ poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var publishedPoem = poem
            publishedPoem.isPublished = true
            publishedPoem.updatedAt = Date()
            allPoems[index] = publishedPoem
            savePoems()
        }
    }
    
    /// 删除诗歌
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
    
    /// 点赞/取消点赞
    func toggleLike(for poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.isLiked.toggle()
            updatedPoem.likeCount += updatedPoem.isLiked ? 1 : -1
            allPoems[index] = updatedPoem
            savePoems()
        }
    }
    
    /// 收藏/取消收藏
    func toggleFavorite(for poem: Poem) {
        if let index = allPoems.firstIndex(where: { $0.id == poem.id }) {
            var updatedPoem = allPoems[index]
            updatedPoem.isFavorited.toggle()
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
    
    /// 加载公共诗歌（示例数据）
    private func loadPublicPoems() {
        // 首次启动时，加载示例诗歌
        if UserDefaults.standard.bool(forKey: "has_loaded_public_poems") == false {
            allPoems.append(contentsOf: Poem.examples)
            UserDefaults.standard.set(true, forKey: "has_loaded_public_poems")
            savePoems()
        }
    }
    
    // MARK: - 搜索和筛选
    
    /// 按标签搜索
    func searchByTag(_ tag: String) -> [Poem] {
        allPoems.filter { $0.isPublished && $0.tags.contains(tag) }
    }
    
    /// 按关键词搜索
    func search(keyword: String) -> [Poem] {
        let lowercased = keyword.lowercased()
        return allPoems.filter { poem in
            poem.isPublished && (
                poem.title.lowercased().contains(lowercased) ||
                poem.content.lowercased().contains(lowercased) ||
                poem.authorName.lowercased().contains(lowercased)
            )
        }
    }
    
    /// 按创作模式筛选
    func filterByMode(_ mode: WritingMode) -> [Poem] {
        allPoems.filter { $0.isPublished && $0.writingMode == mode }
    }
    
    // MARK: - 统计数据
    
    /// 我的统计
    var myStats: (totalPoems: Int, totalDrafts: Int, totalLikes: Int) {
        let published = myPublishedPoems.count
        let drafts = myDrafts.count
        let likes = myPublishedPoems.reduce(0) { $0 + $1.likeCount }
        return (published, drafts, likes)
    }
    
    // MARK: - 数据管理
    
    /// 删除所有诗歌（用于重置数据）
    func deleteAll() {
        allPoems.removeAll()
        savePoems()
        UserDefaults.standard.set(false, forKey: "has_loaded_public_poems")
    }
}

