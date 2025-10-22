# 🚀 Supabase 后端配置指南

## 📝 第一步：创建 Supabase 项目

### 1. 注册账号
访问：https://supabase.com
- 使用 GitHub 账号登录（推荐）
- 或者使用邮箱注册

### 2. 创建新项目
点击 `New Project`，填写：
- **Project name**: `shanhai-poetry`
- **Database Password**: 设置一个强密码（保存好！）
- **Region**: `Southeast Asia (Singapore)` （亚洲节点，速度较快）
- **Pricing Plan**: `Free` （免费版）

等待 2-3 分钟，项目创建完成。

---

## 🗄️ 第二步：创建数据库表

### 1. 进入 SQL Editor
在左侧菜单选择：`SQL Editor` → `New Query`

### 2. 复制粘贴 SQL
打开 `supabase_schema.sql` 文件，全选复制，粘贴到 SQL 编辑器

### 3. 运行 SQL
点击右下角 `Run` 按钮（或按 Cmd/Ctrl + Enter）

### 4. 验证创建成功
在左侧菜单选择：`Table Editor`

应该看到以下表：
- ✅ profiles（用户资料）
- ✅ poems（诗歌）
- ✅ likes（点赞）
- ✅ favorites（收藏）
- ✅ comments（评论）

---

## 🔐 第三步：配置认证

### 1. 开启 Apple 登录（推荐）

进入：`Authentication` → `Providers` → `Apple`

#### 获取 Apple 凭证
1. 访问：https://developer.apple.com/account
2. Certificates, IDs & Profiles → Keys
3. 创建新 Key：
   - Name: `Shanhai Poetry Supabase`
   - 勾选 `Sign in with Apple`
   - 选择你的 App ID
4. 下载 `.p8` 文件
5. 记录：
   - **Key ID**: `XXXXXXXXXX`
   - **Team ID**: `XXXXXXXXXX`

#### 在 Supabase 配置
- **Enabled**: 打开
- **Client ID**: 你的 Bundle ID（如 `com.shanhai.poetry`）
- **Secret Key**: 从 `.p8` 文件复制内容
- **Key ID**: 上面记录的 Key ID
- **Team ID**: 上面记录的 Team ID

### 2. 开启邮箱登录（备选）

进入：`Authentication` → `Providers` → `Email`
- **Enabled**: 打开
- **Confirm email**: 可选（建议关闭，简化流程）

---

## 🔑 第四步：获取 API 密钥

### 1. 进入 Settings
点击左侧菜单：`Settings` → `API`

### 2. 复制以下信息
记录到安全的地方：

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **重要**：
- `anon public key` - 用于客户端（可以公开）
- `service_role key` - 用于后台管理（绝不能泄露）

---

## 📱 第五步：集成到 iOS 项目

### 1. 安装 Supabase SDK

打开 `BetweenLines.xcodeproj`，在 Xcode 中：

1. File → Add Package Dependencies
2. 搜索：`https://github.com/supabase/supabase-swift`
3. Version: `2.0.0` 或最新版
4. Add Package

选择库：
- ✅ Supabase
- ✅ Auth
- ✅ Functions
- ✅ PostgREST
- ✅ Realtime
- ✅ Storage

### 2. 配置 API 密钥

打开 `BetweenLines/Services/SupabaseClient.swift`，填入你的信息：

```swift
let SUPABASE_URL = "https://xxxxxxxxxxxxx.supabase.co"
let SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## ✅ 第六步：测试连接

### 1. 运行 App
在 Xcode 按 `Cmd + R` 运行

### 2. 注册新用户
- 使用 Apple 登录，或
- 使用邮箱注册：test@example.com

### 3. 验证数据
回到 Supabase Dashboard：
- `Authentication` → `Users`
- 应该看到新注册的用户 ✅

- `Table Editor` → `profiles`
- 应该看到用户资料 ✅

---

## 🧪 测试场景

### 测试 1: 用户注册登录
- ✅ 注册新用户
- ✅ 登出
- ✅ 再次登录

### 测试 2: 发布诗歌到广场
- ✅ 写一首诗
- ✅ 发布到广场
- ✅ 在【赏诗】页面看到自己的诗

### 测试 3: 点赞功能
- ✅ 点赞别人的诗
- ✅ 点赞数实时更新
- ✅ 取消点赞

### 测试 4: 多设备同步
- ✅ 在设备 A 发布诗歌
- ✅ 在设备 B 看到诗歌
- ✅ 在设备 B 点赞
- ✅ 在设备 A 看到点赞数增加

---

## 🔧 常见问题

### Q1: "Failed to fetch" 错误
**原因**：网络问题或 API 密钥错误
**解决**：
1. 检查网络连接
2. 确认 SUPABASE_URL 和 SUPABASE_ANON_KEY 正确
3. 在 Supabase Dashboard 检查项目状态

### Q2: "Row Level Security policy violated" 错误
**原因**：RLS 策略阻止了操作
**解决**：
1. 确认用户已登录
2. 检查 SQL 中的 RLS 策略是否正确
3. 在 Supabase SQL Editor 运行：
   ```sql
   SELECT * FROM public.profiles WHERE id = auth.uid();
   ```
   验证当前用户

### Q3: 诗歌列表为空
**原因**：数据库没有已发布的诗歌
**解决**：
1. 写一首诗并发布
2. 或在 SQL Editor 插入测试数据：
   ```sql
   -- 获取你的 user_id
   SELECT id FROM auth.users LIMIT 1;
   
   -- 插入测试诗歌（替换 'your-user-id'）
   INSERT INTO public.poems (title, content, author_id, is_published, is_draft)
   VALUES ('测试诗', '这是一首测试诗', 'your-user-id', TRUE, FALSE);
   ```

### Q4: Apple 登录失败
**原因**：配置错误
**解决**：
1. 确认 Bundle ID 正确
2. 确认 Apple Key 没有过期
3. 确认 Team ID 和 Key ID 正确
4. 重新下载 `.p8` 文件

---

## 📊 数据库管理

### 查看所有诗歌
```sql
SELECT 
  p.title,
  p.content,
  p.like_count,
  prof.username AS author
FROM public.poems p
JOIN public.profiles prof ON p.author_id = prof.id
WHERE p.is_published = TRUE
ORDER BY p.created_at DESC;
```

### 查看点赞统计
```sql
SELECT 
  prof.username,
  prof.total_likes_received,
  prof.total_poems
FROM public.profiles prof
ORDER BY prof.total_likes_received DESC;
```

### 清空测试数据
```sql
-- ⚠️ 危险操作！会删除所有数据
TRUNCATE TABLE public.likes CASCADE;
TRUNCATE TABLE public.favorites CASCADE;
TRUNCATE TABLE public.comments CASCADE;
TRUNCATE TABLE public.poems CASCADE;
-- 不要删除 profiles，因为它关联 auth.users
```

---

## 🚀 生产环境注意事项

### 1. 安全配置
- ❌ 不要在代码里写死 `service_role key`
- ✅ 使用环境变量或 Xcode Build Configuration
- ✅ 开启 RLS（Row Level Security）
- ✅ 定期检查 Supabase Dashboard 的安全警告

### 2. 性能优化
- ✅ 使用索引（已在 schema.sql 中创建）
- ✅ 限制查询数量（`LIMIT 20`）
- ✅ 使用 Realtime 而不是轮询
- ✅ 缓存常用数据

### 3. 备份策略
- ✅ Supabase 自动每日备份（保留 7 天）
- ✅ 可在 Settings → Database → Backups 手动创建备份
- ✅ 可导出数据：pg_dump

### 4. 监控
- 访问：Settings → Reports
- 查看：
  - API 请求量
  - 数据库大小
  - 用户活跃度

---

## 💰 免费额度

Supabase Free 计划：
- ✅ 500 MB 数据库存储
- ✅ 5 GB 带宽/月
- ✅ 50,000 月活跃用户
- ✅ 2 GB 文件存储
- ✅ 社区支持

**超出后怎么办？**
- 升级到 Pro 计划：$25/月
- 或自行托管 Supabase（开源）

---

## 📚 下一步

配置完成后：
1. ✅ 运行 App 测试
2. ✅ 查看 `Services/AuthService.swift` - 认证逻辑
3. ✅ 查看 `Services/PoemService.swift` - 诗歌 CRUD
4. ✅ 查看 `Models/RemotePoem.swift` - 远程数据模型
5. ✅ 开始开发！🎉

有问题随时查看：https://supabase.com/docs

