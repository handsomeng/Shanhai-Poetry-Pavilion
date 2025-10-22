//
//  RealtimeService.swift
//  山海诗馆
//
//  实时监听服务 - 监听诗歌变化、点赞等实时更新
//  ⚠️ 可选功能，需要在 Supabase 配置后启用
//

import Foundation
import Supabase
import Combine

/// 实时监听服务
@MainActor
class RealtimeService: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 是否已连接
    @Published var isConnected = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    
    private var poemsChannel: RealtimeChannel?
    private var likesChannel: RealtimeChannel?
    
    // MARK: - 单例
    
    static let shared = RealtimeService()
    
    private init() {}
    
    // MARK: - 连接/断开
    
    /// 开始监听（订阅所有频道）
    func connect() {
        guard AuthService.shared.isAuthenticated else {
            print("⚠️ 未登录，跳过实时监听")
            return
        }
        
        subscribeToPoems()
        subscribeToLikes()
        
        isConnected = true
        print("✅ 实时监听已启动")
    }
    
    /// 断开连接
    func disconnect() {
        Task {
            if let poemsChannel = poemsChannel {
                await supabase.realtime.remove(poemsChannel)
            }
            
            if let likesChannel = likesChannel {
                await supabase.realtime.remove(likesChannel)
            }
            
            self.poemsChannel = nil
            self.likesChannel = nil
            self.isConnected = false
            
            print("✅ 实时监听已停止")
        }
    }
    
    // MARK: - 订阅频道
    
    /// 订阅诗歌变化
    private func subscribeToPoems() {
        // 监听 poems 表的 INSERT 和 UPDATE
        poemsChannel = supabase.realtime.channel("public:poems")
        
        Task {
            guard let channel = poemsChannel else { return }
            
            // 监听新诗歌发布
            let insertions = await channel.postgresChange(InsertAction.self, table: "poems")
            
            // 监听诗歌更新
            let updates = await channel.postgresChange(UpdateAction.self, table: "poems")
            
            // 订阅
            await channel.subscribe()
            
            // 处理插入事件
            for await insertion in insertions {
                handlePoemInserted(insertion.record)
            }
            
            // 处理更新事件
            for await update in updates {
                handlePoemUpdated(update.record)
            }
        }
    }
    
    /// 订阅点赞变化
    private func subscribeToLikes() {
        // 监听 likes 表的 INSERT 和 DELETE
        likesChannel = supabase.realtime.channel("public:likes")
        
        Task {
            guard let channel = likesChannel else { return }
            
            // 监听新点赞
            let insertions = await channel.postgresChange(InsertAction.self, table: "likes")
            
            // 监听取消点赞
            let deletions = await channel.postgresChange(DeleteAction.self, table: "likes")
            
            // 订阅
            await channel.subscribe()
            
            // 处理插入事件
            for await insertion in insertions {
                handleLikeAdded(insertion.record)
            }
            
            // 处理删除事件
            for await deletion in deletions {
                handleLikeRemoved(deletion.oldRecord)
            }
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理新诗歌发布
    private func handlePoemInserted(_ record: [String: Any]) {
        print("📝 新诗歌发布：\(record)")
        
        // TODO: 刷新广场诗歌列表
        Task {
            try? await PoemService.shared.fetchSquarePoems(limit: 20)
        }
    }
    
    /// 处理诗歌更新
    private func handlePoemUpdated(_ record: [String: Any]) {
        print("📝 诗歌已更新：\(record)")
        
        // TODO: 更新本地缓存中的诗歌
    }
    
    /// 处理新点赞
    private func handleLikeAdded(_ record: [String: Any]) {
        print("💖 新点赞：\(record)")
        
        guard let poemIdString = record["poem_id"] as? String,
              let poemId = UUID(uuidString: poemIdString) else {
            return
        }
        
        // 更新本地诗歌的点赞数
        updateLocalPoemLikeCount(poemId: poemId, increment: true)
    }
    
    /// 处理取消点赞
    private func handleLikeRemoved(_ oldRecord: [String: Any]) {
        print("💔 取消点赞：\(oldRecord)")
        
        guard let poemIdString = oldRecord["poem_id"] as? String,
              let poemId = UUID(uuidString: poemIdString) else {
            return
        }
        
        // 更新本地诗歌的点赞数
        updateLocalPoemLikeCount(poemId: poemId, increment: false)
    }
    
    // MARK: - 辅助方法
    
    /// 更新本地诗歌的点赞数
    private func updateLocalPoemLikeCount(poemId: UUID, increment: Bool) {
        let poemService = PoemService.shared
        
        if let index = poemService.squarePoems.firstIndex(where: { $0.id == poemId }) {
            poemService.squarePoems[index].likeCount += increment ? 1 : -1
        }
    }
}

// MARK: - Realtime 扩展（简化使用）

extension RealtimeService {
    
    /// 监听特定诗歌的变化
    /// - Parameter poemId: 诗歌 ID
    /// - Returns: 监听频道
    func observePoem(poemId: UUID) -> RealtimeChannel {
        let channel = supabase.realtime.channel("poem:\(poemId.uuidString)")
        
        Task {
            await channel.subscribe()
        }
        
        return channel
    }
    
    /// 监听特定用户的诗歌
    /// - Parameter userId: 用户 ID
    /// - Returns: 监听频道
    func observeUserPoems(userId: UUID) -> RealtimeChannel {
        let channel = supabase.realtime.channel("user_poems:\(userId.uuidString)")
        
        Task {
            await channel.subscribe()
        }
        
        return channel
    }
}

// MARK: - 使用示例

/*
 在 App 启动时：
 
 @main
 struct BetweenLinesApp: App {
     @StateObject private var authService = AuthService.shared
     @StateObject private var realtimeService = RealtimeService.shared
     
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .onAppear {
                     // 登录后启动实时监听
                     if authService.isAuthenticated {
                         realtimeService.connect()
                     }
                 }
                 .onDisappear {
                     realtimeService.disconnect()
                 }
         }
     }
 }
 
 在视图中监听特定诗歌：
 
 struct PoemDetailView: View {
     let poemId: UUID
     
     @StateObject private var realtimeService = RealtimeService.shared
     @State private var channel: RealtimeChannel?
     
     var body: some View {
         // ...
         .onAppear {
             channel = realtimeService.observePoem(poemId: poemId)
         }
         .onDisappear {
             if let channel = channel {
                 Task {
                     await supabase.realtime.remove(channel)
                 }
             }
         }
     }
 }
 */

