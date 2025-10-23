# Apple Sign In 排查指南

## ❌ 当前错误

```
Authorization failed: Error Domain=AKAuthenticationError Code=-7071
ASAuthorizationController credential request failed with error: 
Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000
```

---

## 🔍 排查步骤

### 第一步：检查真机设置（最常见原因）

#### 1.1 确认已登录 Apple ID
```
设置 -> [你的名字]
```
- ✅ 必须登录 iCloud 账号
- ✅ 必须是真实的 Apple ID（不是测试账号）

#### 1.2 确认双重认证已开启
```
设置 -> [你的名字] -> 密码与安全性 -> 双重认证
```
- ✅ 必须开启双重认证
- ⚠️ 如果显示"建议开启"，点击开启

#### 1.3 检查设备限制
```
设置 -> 屏幕使用时间 -> 内容和隐私访问限制
```
- ✅ "账户更改"必须是"允许"
- ✅ 不能有家长控制限制

---

### 第二步：检查 Xcode 配置

#### 2.1 确认 Bundle ID
打开 Xcode:
```
项目设置 -> TARGETS -> BetweenLines -> General -> Identity
Bundle Identifier: com.shanhai.poetry ✅
```

#### 2.2 确认能力已开启
```
项目设置 -> TARGETS -> BetweenLines -> Signing & Capabilities
```
点击 "+ Capability"，搜索 "Sign in with Apple"
- ✅ 如果已经添加，会显示 "Sign in with Apple" 
- ✅ 如果没有，点击添加

#### 2.3 确认开发团队
```
项目设置 -> TARGETS -> BetweenLines -> Signing & Capabilities -> Team
```
- ⚠️ 必须选择一个 Apple 开发者账号
- ⚠️ 免费账号也可以，但有限制

---

### 第三步：检查 Apple Developer 配置

#### 3.1 访问 Apple Developer 网站
https://developer.apple.com/account/resources/identifiers/list

#### 3.2 找到你的 App ID
搜索: `com.shanhai.poetry`

#### 3.3 确认能力已启用
点击 App ID，检查 "Capabilities" 列表:
- ✅ "Sign in with Apple" 必须是 "Enabled"
- 如果是 "Configurable"，点击 "Edit" 启用它

---

### 第四步：检查 Supabase 配置

#### 4.1 检查 Bundle ID
```
Supabase Dashboard -> Authentication -> Providers -> Apple
```

**iOS Bundle ID** 应该是:
```
com.shanhai.poetry
```

#### 4.2 检查 Redirect URL（可选）
```
https://bfudbchnwwckqryoiwst.supabase.co/auth/v1/callback
```

---

## 🛠️ 快速修复方案

### 方案 1：重置真机 Apple ID（推荐）

1. 退出当前 Apple ID:
   ```
   设置 -> [你的名字] -> 退出登录
   ```

2. 重新登录:
   ```
   设置 -> 登录 iPhone -> 输入 Apple ID 和密码
   ```

3. 确保开启双重认证

4. 重启设备

5. 重新在 Xcode 运行 App

---

### 方案 2：重新配置 Xcode（如果方案 1 不行）

1. 在 Xcode 中，删除 "Sign in with Apple" 能力:
   ```
   Signing & Capabilities -> Sign in with Apple -> 点击 "-" 删除
   ```

2. 清理项目:
   ```
   Product -> Clean Build Folder (Shift + Cmd + K)
   ```

3. 重新添加 "Sign in with Apple" 能力:
   ```
   点击 "+ Capability" -> 搜索 "Sign in with Apple" -> 添加
   ```

4. 重新运行

---

### 方案 3：检查网络和服务状态

1. 检查设备网络:
   - ✅ Wi-Fi 或蜂窝数据正常
   - ✅ 可以访问 iCloud.com

2. 检查 Apple 服务状态:
   https://www.apple.com/support/systemstatus/
   - 确认 "Apple ID" 和 "iCloud" 服务正常

---

## 🚨 常见问题

### Q1: 为什么模拟器上不能用？
**A:** Apple Sign In 在模拟器上不稳定，必须用真机测试。

### Q2: 我没有付费开发者账号可以用吗？
**A:** 可以！免费账号也支持 Apple Sign In，但有一些限制:
- 只能在自己的设备上测试
- 不能发布到 App Store
- 描述文件 7 天过期

### Q3: 为什么点击按钮没反应？
**A:** 检查:
1. 设备是否登录 Apple ID
2. 双重认证是否开启
3. Console 中的错误信息

### Q4: 错误码 -7071 是什么意思？
**A:** 这通常表示:
- 设备未登录 Apple ID
- 双重认证未开启
- 设备有限制或家长控制

### Q5: 错误码 1000 是什么意思？
**A:** 这是一个通用错误，可能是:
- 认证服务不可用
- 配置错误
- 网络问题

---

## ✅ 验证成功的标志

如果配置正确，你应该看到:

1. 点击 "使用 Apple 登录" 按钮
2. 弹出 Apple 原生认证窗口
3. 可以用 Face ID / Touch ID / 密码认证
4. 认证成功后，App 自动登录

Console 应该输出:
```
✅ 获取到 identityToken
✅ 获取到 userId: xxx
✅ Apple 登录成功
```

---

## 📞 还是不行？

如果以上步骤都试过了还是不行，请提供:

1. **设备信息**:
   - iPhone 型号
   - iOS 版本
   - 是否登录 Apple ID
   - 是否开启双重认证

2. **开发者账号**:
   - 免费账号还是付费账号
   - Team ID

3. **完整的 Console 错误日志**

---

## 🎯 下一步

修复 Apple Sign In 后，还需要:
1. ✅ 测试注册流程
2. ✅ 测试登录流程
3. ✅ 测试发布诗歌到广场
4. ✅ 测试点赞和收藏功能
5. ✅ 测试退出登录

可以参考 `Backend/TESTING_GUIDE.md` 进行完整测试。

