# 🍎 Apple Sign In 配置指南

## 第一步：Xcode 项目配置

### 1. 添加 Sign in with Apple Capability

1. 在 Xcode 中打开项目
2. 选择项目 Target：`BetweenLines`
3. 点击顶部的 **Signing & Capabilities** 标签
4. 点击左上角的 **+ Capability** 按钮
5. 搜索并添加 **Sign in with Apple**

**截图提示：**
```
Signing & Capabilities
  ├── Automatically manage signing ✓
  ├── Team: Your Team
  ├── Bundle Identifier: com.yourcompany.BetweenLines
  └── + Sign in with Apple  ← 添加这个
```

### 2. 验证配置成功

添加成功后，你应该能看到：

```
Signing & Capabilities
  └── Sign in with Apple
      └── ✓ Enabled
```

---

## 第二步：Supabase 配置 Apple Provider

### 1. 获取 Apple 配置信息

#### 方法 A：使用 App ID Prefix（推荐，简单）

1. 在 Xcode 的 **Signing & Capabilities** 中
2. 找到 **Team ID**（例如：`ABC123XYZ`）
3. 找到 **Bundle Identifier**（例如：`com.yourcompany.BetweenLines`）

#### 方法 B：从 Apple Developer 获取（完整配置）

1. 登录 https://developer.apple.com/account
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers**
4. 找到你的 App ID
5. 记录：
   - **App ID Prefix** (Team ID)
   - **Bundle ID**

### 2. 配置 Supabase

1. 登录 Supabase Dashboard: https://supabase.com/dashboard
2. 选择你的项目：`bfudbchnwwckqryoiwst`
3. 进入 **Authentication** → **Providers**
4. 找到 **Apple** 并启用
5. 填写配置：

```
Enable Sign in with Apple: ✓

Service ID: com.yourcompany.BetweenLines
(这是你的 Bundle Identifier)

Authorized Client IDs:
(留空即可，使用默认配置)

Secret Key (from Apple):
(可选，高级配置需要。测试阶段可以跳过)
```

6. 点击 **Save**

---

## 第三步：测试 Apple Sign In

### 1. 运行 App

1. 在 Xcode 中按 **Cmd+R** 运行 App
2. 点击底部 Tab Bar 的"赏诗"
3. 点击右上角"登录"

### 2. 测试流程

你应该能看到：

```
┌─────────────────────────┐
│   欢迎来到山海诗馆      │
│  登录以发布和管理你的诗歌│
├─────────────────────────┤
│                         │
│  ⚫ 使用 Apple 登录      │ ← 主推荐
│                         │
│    推荐使用 Apple 登录， │
│      快速且安全          │
│                         │
├─────────────────────────┤
│         或              │
├─────────────────────────┤
│  📧 使用邮箱登录        │ ← 备选方案
└─────────────────────────┘
```

### 3. 点击"使用 Apple 登录"

**首次登录：**
- Apple 会弹出系统对话框
- 选择是否分享姓名和邮箱
- 可以选择"隐藏我的邮箱"
- Face ID / Touch ID 验证
- 登录成功！

**后续登录：**
- 直接 Face ID / Touch ID
- 秒速登录！

---

## 🎯 Apple Sign In 的优势

### 1. 用户体验
- ✅ 一键登录，无需记密码
- ✅ Face ID / Touch ID 快速认证
- ✅ 自动填充姓名和邮箱
- ✅ 可以隐藏真实邮箱（隐私保护）

### 2. 开发优势
- ✅ 无需管理密码
- ✅ Apple 处理所有安全问题
- ✅ 符合 App Store 审核要求
- ✅ 提升用户留存率

### 3. 隐私保护
- ✅ 用户可以选择"隐藏我的邮箱"
- ✅ Apple 会生成中继邮箱（例如：`xxx@privaterelay.appleid.com`）
- ✅ 邮件会转发到用户真实邮箱
- ✅ 用户可以随时撤销访问权限

---

## 🐛 常见问题

### 1. 编译错误：Missing entitlement

**问题：**
```
Entitlement com.apple.developer.applesignin missing
```

**解决：**
1. 确认已在 **Signing & Capabilities** 中添加 **Sign in with Apple**
2. 清理项目（Cmd+Shift+K）
3. 重新编译

### 2. 登录失败：Invalid credentials

**问题：** 点击 Apple 登录后显示"无法获取凭证"

**检查：**
1. Supabase Dashboard → Authentication → Providers → Apple 是否启用
2. Service ID 是否正确（应该是你的 Bundle Identifier）
3. 检查网络连接

### 3. 首次登录后，再次登录不显示姓名

**这是正常的！**

- Apple 只在**首次授权**时提供姓名和邮箱
- 后续登录只提供 User ID
- 我们的代码已经处理了这种情况：
  ```swift
  if let fullName = credential.fullName {
      // 使用 Apple 提供的姓名（仅首次）
  } else {
      // 从数据库获取已保存的用户名（后续登录）
  }
  ```

### 4. 测试时想重置授权

**在 iPhone/模拟器上：**
1. 设置 → Apple ID → 密码与安全性
2. 选择"使用 Apple 登录的 App"
3. 找到"山海诗馆"
4. 点击"停止使用 Apple ID"

---

## 🚀 高级配置（可选）

### 1. 配置 Service ID（用于 Web）

如果你未来想在网页上也使用 Apple 登录：

1. 访问 https://developer.apple.com/account
2. Identifiers → Services IDs → + (新建)
3. 配置 Service ID
4. 添加到 Supabase 配置

### 2. 配置 Private Key（用于服务器端）

1. 在 Apple Developer 创建 Key
2. 下载 `.p8` 文件
3. 上传到 Supabase

**当前项目不需要，使用客户端流程即可！**

---

## ✅ 验证配置成功

### 检查清单

- [ ] Xcode 中已添加 **Sign in with Apple** Capability
- [ ] Supabase 中 Apple Provider 已启用
- [ ] Service ID 设置为 Bundle Identifier
- [ ] App 能正常编译运行
- [ ] 点击"使用 Apple 登录"能弹出系统对话框
- [ ] 登录成功后能看到用户名
- [ ] 重启 App 后仍保持登录状态

---

## 📱 用户流程

### 首次使用（从未注册）

1. 打开 App
2. 点击"登录"
3. 点击"使用 Apple 登录"
4. Apple 对话框：
   - 显示你的 Apple ID
   - 选择"使用全名"或"编辑姓名"
   - 选择"分享我的邮箱"或"隐藏我的邮箱"
5. Face ID / Touch ID 验证
6. **自动注册 + 登录成功！**
7. 右上角显示用户名

### 老用户登录

1. 打开 App
2. 点击"登录"
3. 点击"使用 Apple 登录"
4. Face ID / Touch ID 验证
5. **秒速登录！**

### 使用邮箱登录（备选）

1. 打开 App
2. 点击"登录"
3. 点击"使用邮箱登录"
4. 输入邮箱和密码
5. 点击"登录"或"注册"

---

## 🎉 完成！

现在你的 App 支持：

- ✅ **Apple Sign In**（主推荐）
- ✅ **邮箱登录**（备选方案）
- ✅ 自动 Session 管理
- ✅ 隐私保护

用户可以选择最方便的登录方式！

