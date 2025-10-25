import Foundation
import SwiftUI
import CloudKit

/// 用户身份服务 - 管理匿名用户 ID 和笔名
/// 替代 AuthService，使用设备 ID + iCloud 同步实现无登录方案
class UserIdentityService: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 用户笔名
    @Published var penName: String {
        didSet {
            savePenName(penName)
        }
    }
    
    // MARK: - Private Properties
    
    /// 设备唯一标识（永久保存）
    @AppStorage("deviceUserId") private var storedUserId: String?
    
    /// 笔名存储
    @AppStorage("userPenName") private var storedPenName: String = ""
    
    // MARK: - Computed Properties
    
    /// 当前用户 ID（自动生成并永久保存）
    var userId: String {
        if let id = storedUserId {
            return id
        }
        
        // 首次使用，生成永久设备 ID
        let newId = UUID().uuidString
        storedUserId = newId
        print("🆔 [UserIdentityService] 生成新设备 ID: \(newId)")
        return newId
    }
    
    /// 是否已设置笔名
    var hasSetPenName: Bool {
        !penName.isEmpty
    }
    
    // MARK: - Initialization
    
    init() {
        // 从 iCloud 恢复笔名（跨设备同步）
        if let cloudPenName = NSUbiquitousKeyValueStore.default.string(forKey: "penName"),
           !cloudPenName.isEmpty {
            self.penName = cloudPenName
            print("☁️ [UserIdentityService] 从 iCloud 恢复笔名: \(cloudPenName)")
        } else {
            self.penName = storedPenName
        }
        
        // 监听 iCloud 变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        
        // 确保有用户 ID
        _ = userId
    }
    
    // MARK: - Public Methods
    
    /// 设置笔名
    func setPenName(_ name: String) {
        penName = name
    }
    
    /// 重置用户数据（用于测试或重置功能）
    func resetUserData() {
        storedUserId = nil
        storedPenName = ""
        penName = ""
        
        // 清除 iCloud 数据
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "penName")
        NSUbiquitousKeyValueStore.default.synchronize()
        
        print("🔄 [UserIdentityService] 用户数据已重置")
    }
    
    // MARK: - Private Methods
    
    /// 保存笔名到本地和 iCloud
    private func savePenName(_ name: String) {
        storedPenName = name
        
        // 同步到 iCloud
        NSUbiquitousKeyValueStore.default.set(name, forKey: "penName")
        NSUbiquitousKeyValueStore.default.synchronize()
        
        print("💾 [UserIdentityService] 笔名已保存: \(name)")
    }
    
    /// iCloud 数据变化通知
    @objc private func iCloudStoreDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }
        
        // 只处理外部变化（其他设备的修改）
        if reasonForChange == NSUbiquitousKeyValueStoreServerChange ||
           reasonForChange == NSUbiquitousKeyValueStoreInitialSyncChange {
            
            if let cloudPenName = NSUbiquitousKeyValueStore.default.string(forKey: "penName"),
               cloudPenName != penName {
                DispatchQueue.main.async {
                    self.penName = cloudPenName
                    print("🔄 [UserIdentityService] iCloud 笔名已更新: \(cloudPenName)")
                }
            }
        }
    }
}




