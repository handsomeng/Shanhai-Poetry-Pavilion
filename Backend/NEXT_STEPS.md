# 🎯 后端集成 - 下一步指南

## ✅ 已完成（第一阶段）

1. ✅ 数据库设计（supabase_schema.sql）
2. ✅ 配置指南（SUPABASE_SETUP.md）
3. ✅ Supabase 客户端配置
4. ✅ 数据模型（RemotePoem, UserProfile）

---

## 📋 待完成任务

### 🔴 高优先级（核心功能）

#### 1. 创建 Supabase 项目 ⏰ 30分钟
按照 `SUPABASE_SETUP.md` 的步骤：
1. 注册 Supabase 账号
2. 创建项目
3. 执行 SQL 脚本
4. 复制 API 密钥到 `SupabaseClient.swift`

#### 2. 安装 Supabase SDK ⏰ 5分钟
```
1. 打开 Xcode
2. File → Add Package Dependencies
3. 搜索：https://github.com/supabase/supabase-swift
4. 选择 Version: 2.0.0 或最新
5. 添加所有模块（Supabase, Auth, PostgREST, Realtime, Storage）
```

#### 3. 创建认证服务 ⏰ 1小时

创建文件：`Services/AuthService.swift`

```swift
//
//  AuthService.swift
//  山海诗馆
//

import Foundation
import Supabase
import Auth

/// 认证服务
@MainActor
class AuthService: ObservableObject {
    
    // MARK: - 发布属性
    
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = AuthService()
    
    private init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - 认证状态
    
    /// 检查登录状态
    func checkAuthStatus() async {
        do {
            currentUser = try await supabase.auth.session.user
            if currentUser != nil {
                await fetchUserProfile()
                isAuthenticated = true
            }
        } catch {
            print("检查登录状态失败：\(error)")
        }
    }
    
    /// 获取用户资料
    func fetchUserProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let profile: UserProfile = try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            currentProfile = profile
        } catch {
            print("获取用户资料失败：\(error)")
        }
    }
    
    // MARK: - Apple 登录
    
    /// Apple 登录
    func signInWithApple() async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // TODO: 实现 Apple 登录
        // 需要配置 Apple Sign In
    }
    
    // MARK: - 邮箱登录/注册
    
    /// 邮箱注册
    func signUpWithEmail(email: String, password: String, username: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // 1. 注册用户
            let session = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            guard let user = session.user else {
                throw AuthError.registrationFailed
            }
            
            // 2. 创建用户资料
            try await createUserProfile(userId: user.id, username: username)
            
            // 3. 更新状态
            currentUser = user
            await fetchUserProfile()
            isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 邮箱登录
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            currentUser = session.user
            await fetchUserProfile()
            isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - 登出
    
    /// 登出
    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        currentProfile = nil
        isAuthenticated = false
    }
    
    // MARK: - 辅助方法
    
    /// 创建用户资料
    private func createUserProfile(userId: UUID, username: String) async throws {
        let profileData = UserProfile.createDict(
            userId: userId,
            username: username
        )
        
        try await supabase.database
            .from("profiles")
            .insert(profileData)
            .execute()
    }
}

// MARK: - 错误类型

enum AuthError: LocalizedError {
    case registrationFailed
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .registrationFailed:
            return "注册失败，请稍后重试"
        case .notAuthenticated:
            return "请先登录"
        }
    }
}
```

#### 4. 创建诗歌服务 ⏰ 2小时

创建文件：`Services/PoemService.swift`

```swift
//
//  PoemService.swift
//  山海诗馆
//

import Foundation
import Supabase

/// 诗歌服务
@MainActor
class PoemService: ObservableObject {
    
    // MARK: - 发布属性
    
    @Published var squarePoems: [RemotePoem] = []
    @Published var myPoems: [RemotePoem] = []
    @Published var myDrafts: [RemotePoem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 单例
    
    static let shared = PoemService()
    
    private init() {}
    
    // MARK: - 获取诗歌
    
    /// 获取广场诗歌（最新）
    func fetchSquarePoems(limit: Int = 20) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            squarePoems = try await supabase.database
                .from("square_poems")
                .select()
                .eq("is_published", value: true)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取热门诗歌
    func fetchPopularPoems(limit: Int = 20) async throws {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            squarePoems = try await supabase.database.rpc(
                "get_popular_poems",
                params: ["limit_count": limit]
            ).execute().value
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取我的诗歌
    func fetchMyPoems() async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            myPoems = try await supabase.database
                .from("poems")
                .select()
                .eq("author_id", value: userId.uuidString)
                .eq("is_published", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// 获取我的草稿
    func fetchMyDrafts() async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            myDrafts = try await supabase.database
                .from("poems")
                .select()
                .eq("author_id", value: userId.uuidString)
                .eq("is_draft", value: true)
                .order("updated_at", ascending: false)
                .execute()
                .value
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - 创建/更新诗歌
    
    /// 创建诗歌
    func createPoem(title: String, content: String, isDraft: Bool = true) async throws -> RemotePoem {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        let poemData: [String: AnyEncodable] = [
            "title": AnyEncodable(title),
            "content": AnyEncodable(content),
            "author_id": AnyEncodable(userId.uuidString),
            "is_draft": AnyEncodable(isDraft),
            "is_published": AnyEncodable(!isDraft)
        ]
        
        let poem: RemotePoem = try await supabase.database
            .from("poems")
            .insert(poemData)
            .select()
            .single()
            .execute()
            .value
        
        return poem
    }
    
    /// 更新诗歌
    func updatePoem(_ poem: RemotePoem) async throws {
        try await supabase.database
            .from("poems")
            .update(poem.updateDict)
            .eq("id", value: poem.id.uuidString)
            .execute()
    }
    
    /// 发布到广场
    func publishToSquare(poemId: UUID) async throws {
        let updateData: [String: AnyEncodable] = [
            "is_published": AnyEncodable(true),
            "is_draft": AnyEncodable(false)
        ]
        
        try await supabase.database
            .from("poems")
            .update(updateData)
            .eq("id", value: poemId.uuidString)
            .execute()
    }
    
    // MARK: - 点赞
    
    /// 点赞诗歌
    func likePoem(_ poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        let likeData: [String: String] = [
            "user_id": userId.uuidString,
            "poem_id": poemId.uuidString
        ]
        
        try await supabase.database
            .from("likes")
            .insert(likeData)
            .execute()
    }
    
    /// 取消点赞
    func unlikePoem(_ poemId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        try await supabase.database
            .from("likes")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("poem_id", value: poemId.uuidString)
            .execute()
    }
    
    // MARK: - 删除
    
    /// 删除诗歌
    func deletePoem(_ poemId: UUID) async throws {
        try await supabase.database
            .from("poems")
            .delete()
            .eq("id", value: poemId.uuidString)
            .execute()
    }
}
```

---

### 🟡 中优先级（用户体验）

#### 5. 创建登录/注册页面 ⏰ 2小时

创建文件：`Views/Auth/AuthView.swift`

提供：
- Apple 登录按钮
- 邮箱登录表单
- 邮箱注册表单
- 切换登录/注册模式

#### 6. 修改 ExploreView ⏰ 30分钟

替换 `PoemManager` 为 `PoemService`：
```swift
@StateObject private var poemService = PoemService.shared
```

在 `onAppear` 中加载诗歌：
```swift
.onAppear {
    Task {
        try? await poemService.fetchSquarePoems()
    }
}
```

#### 7. 修改 ProfileView ⏰ 30分钟

使用 `AuthService` 获取用户信息
使用 `PoemService` 获取我的诗歌

---

### 🟢 低优先级（锦上添花）

#### 8. 实时更新 ⏰ 1小时

创建 `RealtimeService` 监听诗歌变化
当有新诗歌发布时，自动刷新列表

#### 9. 搜索功能 ⏰ 1小时

添加搜索栏，支持搜索标题/内容

#### 10. 评论功能 ⏰ 2小时

实现诗歌评论的 UI 和后端交互

---

## 🎯 开发流程

### 阶段 1：配置环境（今天）
1. ✅ 创建 Supabase 项目
2. ✅ 执行 SQL 脚本
3. ✅ 安装 SDK
4. ✅ 配置 API 密钥

### 阶段 2：认证系统（明天）
1. ⏳ 创建 AuthService
2. ⏳ 创建登录/注册页面
3. ⏳ 测试登录流程

### 阶段 3：诗歌功能（后天）
1. ⏳ 创建 PoemService
2. ⏳ 修改 ExploreView
3. ⏳ 修改 ProfileView
4. ⏳ 测试发布/点赞/删除

### 阶段 4：优化（本周末）
1. ⏳ 实时更新
2. ⏳ 错误处理
3. ⏳ 加载状态
4. ⏳ 性能优化

---

## ⚡️ 快速开始

如果你想快速看到效果，按以下顺序：

### 第1步：配置 Supabase（30分钟）
```bash
1. 访问 https://supabase.com
2. 创建项目（等待2-3分钟）
3. SQL Editor → 粘贴 supabase_schema.sql → Run
4. Settings → API → 复制 URL 和 anon key
5. 粘贴到 SupabaseClient.swift
```

### 第2步：安装 SDK（5分钟）
```
Xcode → File → Add Package Dependencies
→ https://github.com/supabase/supabase-swift
→ Add Package
```

### 第3步：测试连接（5分钟）
在 `AppDelegate` 或 `MainTabView` 的 `onAppear` 中：
```swift
.onAppear {
    // 验证配置
    _ = SupabaseConfig.validate()
    
    // 测试查询
    Task {
        do {
            let result = try await supabase.database
                .from("profiles")
                .select()
                .limit(1)
                .execute()
            print("✅ Supabase 连接成功！")
        } catch {
            print("❌ Supabase 连接失败：\(error)")
        }
    }
}
```

运行 App，查看控制台输出。

---

## 🐛 常见问题

### Q: 编译错误 "Cannot find type 'SupabaseClient'"
**A**: 没有正确安装 Supabase SDK，重新添加 Package

### Q: 运行时错误 "Invalid API key"
**A**: API Key 配置错误，重新复制粘贴

### Q: "Row Level Security policy violated"
**A**: RLS 策略阻止，确认已登录且 SQL 脚本正确执行

### Q: 诗歌列表为空
**A**: 数据库没有数据，手动插入测试数据或创建第一首诗

---

## 📚 学习资源

- Supabase 官方文档：https://supabase.com/docs
- Supabase Swift SDK：https://github.com/supabase/supabase-swift
- PostgreSQL 教程：https://www.postgresqltutorial.com
- SwiftUI + Async/Await：https://www.hackingwithswift.com/swift/5.5/async-await

---

## 💡 提示

1. **分步测试**：每完成一个功能就测试，不要等全部完成
2. **查看日志**：Supabase Dashboard → Logs 可以看到所有请求
3. **使用 Postman**：可以先用 Postman 测试 API，确认逻辑正确
4. **保留本地版本**：暂时保留 `PoemManager`，等后端稳定后再完全切换
5. **从简单开始**：先实现登录+查看诗歌，再实现发布+点赞

---

有问题随时问我！🚀

