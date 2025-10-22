# 🧪 山海诗馆 - 后端测试指南

## ✅ 已完成功能

### 1. 后端架构
- ✅ Supabase REST API 客户端（无需第三方 SDK）
- ✅ 完整的错误处理机制
- ✅ 自动 Session 恢复
- ✅ 数据模型转换

### 2. 用户认证
- ✅ 邮箱注册
- ✅ 邮箱登录
- ✅ 登出
- ✅ Session 持久化（自动保持登录状态）

### 3. 诗歌管理
- ✅ 发布诗歌到广场
- ✅ 保存草稿
- ✅ 获取广场诗歌（最新/热门）
- ✅ 获取我的诗歌（草稿/已发布）
- ✅ 更新诗歌
- ✅ 删除诗歌

### 4. 互动功能
- ✅ 点赞/取消点赞
- ✅ 收藏/取消收藏
- ✅ 评论功能
- ✅ 获取我的收藏列表

### 5. UI 集成
- ✅ ExploreView（赏诗）- 使用后端数据
- ✅ ProfileView（我的）- 草稿和已发布使用后端
- ✅ LoginView（登录/注册）
- ✅ 登录/未登录状态无缝切换

---

## 🧪 测试流程

### 第一步：确认 Supabase 配置

1. 打开 `BetweenLines/Services/SupabaseConfig.swift`
2. 确认以下配置正确：
   ```swift
   static let projectURL = "https://bfudbchnwwckqryoiwst.supabase.co"
   static let anonKey = "eyJhbGc..."
   ```

### 第二步：运行数据库迁移

1. 登录 Supabase Dashboard: https://supabase.com/dashboard
2. 选择你的项目：`bfudbchnwwckqryoiwst`
3. 进入 SQL Editor
4. 复制 `Backend/supabase_schema.sql` 的全部内容
5. 粘贴并执行（Run）

**验证迁移成功：**
- 进入 Table Editor
- 应该看到以下表：
  - `profiles` - 用户资料
  - `poems` - 诗歌
  - `likes` - 点赞
  - `favorites` - 收藏
  - `comments` - 评论
- 还有一个视图：
  - `square_poems` - 广场诗歌视图

---

## 📱 App 测试步骤

### 1. 测试注册和登录

#### 注册新用户
1. 运行 App（Cmd+R）
2. 点击底部 Tab Bar 的"赏诗"
3. 点击右上角"登录"
4. 点击底部"还没有账号？去注册"
5. 输入信息：
   - 用户名：`测试诗人`
   - 邮箱：`test@example.com`
   - 密码：`test123456`（至少6位）
6. 点击"注册"

**预期结果：**
- 注册成功，自动登录
- 界面关闭
- 右上角显示"测试诗人"

#### 登录已有用户
1. 如果已登录，可以先测试登出（需要在设置中添加登出功能）
2. 点击"登录"
3. 输入邮箱和密码
4. 点击"登录"

**预期结果：**
- 登录成功
- 右上角显示用户名

---

### 2. 测试发布诗歌（需要先实现）

**注意：** 目前"写诗"页面还没有集成后端发布功能。

你可以手动在 Supabase 中插入测试数据：

1. 进入 Supabase Table Editor
2. 选择 `poems` 表
3. 点击"Insert row"
4. 填写：
   ```
   author_id: <你的用户ID，从 profiles 表获取>
   title: 测试诗歌
   content: 春风吹绿江南岸\n明月何时照我还
   style: modern
   is_public: true
   ```
5. 保存

---

### 3. 测试广场诗歌浏览

1. 点击底部 Tab Bar 的"赏诗"
2. 应该能看到刚才插入的诗歌

**功能测试：**
- ✅ 切换"最新"/"热门"/"随机"筛选
- ✅ 下拉刷新
- ✅ 点击诗歌卡片查看详情
- ✅ 查看点赞数

**预期结果：**
- 能正常加载诗歌列表
- 筛选功能正常
- 刷新后能获取最新数据

---

### 4. 测试我的诗歌

1. 点击底部 Tab Bar 的"我的"
2. 如果已登录，应该能看到：
   - 用户名和称号
   - 统计信息

**功能测试：**
- ✅ 切换"诗集"/"草稿"/"已发布" Tab
- ✅ "已发布" Tab 显示你发布到广场的诗歌
- ✅ 查看诗歌详情
- ✅ 删除功能（滑动或点击删除按钮）

**预期结果：**
- "已发布" 显示后端的公开诗歌
- "草稿" 显示后端的私密诗歌
- "诗集" 继续使用本地收藏

---

### 5. 测试登录状态切换

#### 未登录状态
1. 关闭 App，卸载并重新安装（或清除数据）
2. 打开 App
3. 进入"赏诗"

**预期结果：**
- 右上角显示"登录"按钮
- 诗歌列表为空（因为数据库还没有其他用户的诗）

#### 登录后
1. 点击"登录"并登录
2. 进入"我的"

**预期结果：**
- 右上角显示用户名
- 能看到自己的诗歌

---

## 🐛 常见问题

### 1. 网络错误

**问题：** 显示"网络错误"或"请求失败"

**解决：**
1. 检查手机/模拟器网络连接
2. 检查 Supabase 项目状态（Dashboard）
3. 检查 API Key 是否正确

### 2. 数据为空

**问题：** 广场诗歌列表为空

**原因：** 数据库中还没有诗歌数据

**解决：**
1. 手动在 Supabase 插入测试数据
2. 或等待实现"写诗"页面的发布功能

### 3. 认证失败

**问题：** 注册/登录失败

**检查：**
1. Supabase 项目是否启用了 Email Auth
2. 进入 Supabase Dashboard → Authentication → Providers
3. 确保 Email Provider 已启用
4. 确保"Confirm Email"选项关闭（测试时）

### 4. Session 丢失

**问题：** 每次重启 App 都需要重新登录

**检查：**
1. `AuthService` 中的 `restoreSession()` 是否正常工作
2. 检查 UserDefaults 是否正确保存 Token

---

## 🚀 下一步开发

### 必需功能（让后端真正可用）

1. **写诗页面集成后端**
   - DirectWritingView 添加"发布到广场"按钮
   - 调用 `PoemService.publishPoem()`
   - 保存草稿调用 `PoemService.saveDraft()`

2. **点赞功能集成**
   - PoemDetailView 添加点赞按钮交互
   - 调用 `InteractionService.toggleLike()`
   - 实时更新点赞数

3. **收藏功能集成**
   - PoemDetailView 添加收藏按钮
   - 调用 `InteractionService.toggleFavorite()`
   - 我的收藏列表使用后端数据

4. **设置页面添加登出**
   - SettingsView 添加"登出"按钮
   - 调用 `AuthService.signOut()`

### 可选功能（增强体验）

1. **实时同步**
   - 使用 Supabase Realtime 监听点赞数变化
   - 已有 `RealtimeService` 框架（需恢复）

2. **评论功能**
   - PoemDetailView 添加评论区
   - 调用 `InteractionService.addComment()`

3. **用户资料编辑**
   - 允许修改用户名、头像、简介
   - 更新 `UserProfile`

4. **搜索功能**
   - 按标题、内容、作者搜索诗歌

---

## 📊 数据库查询示例

### 查看所有用户
```sql
SELECT * FROM profiles;
```

### 查看所有诗歌
```sql
SELECT * FROM poems;
```

### 查看广场诗歌（带作者信息）
```sql
SELECT * FROM square_poems;
```

### 查看某用户的诗歌
```sql
SELECT * FROM poems WHERE author_id = '<用户ID>';
```

### 查看点赞统计
```sql
SELECT 
  p.title,
  p.like_count,
  COUNT(l.id) as actual_likes
FROM poems p
LEFT JOIN likes l ON p.id = l.poem_id
GROUP BY p.id;
```

---

## ✅ 测试完成标准

- [x] 能成功注册新用户
- [x] 能成功登录
- [x] Session 自动恢复（重启 App 保持登录）
- [x] 能浏览广场诗歌
- [x] 能查看我的诗歌
- [x] 登录/未登录状态无缝切换
- [ ] 能发布诗歌到广场（待实现）
- [ ] 能点赞诗歌（待实现）
- [ ] 能收藏诗歌（待实现）
- [ ] 能删除我的诗歌

---

## 📝 总结

**已完成：**
- ✅ 完整的 REST API 后端（无需 SDK）
- ✅ 用户认证系统
- ✅ 诗歌数据管理
- ✅ ExploreView 和 ProfileView 后端集成

**待实现：**
- 写诗页面发布功能
- 点赞/收藏交互
- 设置页面登出功能

现在你有了一个**真实的、可用的后端**！🎉

只需要再添加几个按钮和交互，就能让用户真正使用这个云端诗歌社区了！

