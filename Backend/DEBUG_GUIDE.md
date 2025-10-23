# 🐛 Apple Sign In 调试指南

既然 Apple Developer 配置、Xcode 能力、真机设置都正确，让我们深入调试。

---

## 📱 第一步：确认真机状态

### 1.1 检查 Apple ID 类型
在真机上打开"设置"：
```
设置 -> [你的名字] -> 查看你的 Apple ID
```

⚠️ **重要**：如果你的 Apple ID 是：
- ✅ 普通个人 Apple ID（如 yourname@icloud.com） - 没问题
- ⚠️ 企业/学校账号 - 可能有限制
- ⚠️ 新注册的账号（<24小时） - 可能需要等待激活

### 1.2 测试 iCloud 连接
```
设置 -> [你的名字] -> iCloud
```
- 确保 iCloud 服务可以正常连接
- 如果显示"无法连接到 iCloud"，需要先修复网络

### 1.3 确认无家长控制
```
设置 -> 屏幕使用时间 -> 内容和隐私访问限制
```
- 如果这个选项是灰色的 ✅ 没问题
- 如果可以点击 → 点进去 → "账户更改"必须是"允许"

---

## 🔧 第二步：Xcode 深度检查

### 2.1 检查 Team 配置

打开 Xcode 项目：
```
1. 选择项目 "BetweenLines"
2. 选择 TARGET "BetweenLines"
3. 点击 "Signing & Capabilities" 标签
```

检查以下内容：

#### Team 设置
```
Team: [你的开发者账号名称]
```
- ⚠️ 如果显示 "None"，点击下拉框选择你的 Apple ID
- ⚠️ 如果没有选项，点击 "Add an Account..." 添加你的 Apple ID

#### Bundle Identifier
```
Bundle Identifier: com.shanhai.poetry
```
- ✅ 必须和 Apple Developer 网站上的一致

#### Signing Certificate
```
Signing Certificate: Apple Development 或 iPhone Developer
```
- ✅ 如果显示黄色或红色警告，点击 "Try Again" 或 "Fix Issue"

#### Provisioning Profile
```
Provisioning Profile: Xcode Managed Profile
```
- ✅ 让 Xcode 自动管理即可

### 2.2 确认 Entitlements 文件

在 Xcode 项目导航器中，找到：
```
BetweenLines/BetweenLines.entitlements
```

文件内容应该是：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
</plist>
```

如果不一样，说明有问题。

---

## 🧪 第三步：添加详细日志

我们需要在代码中添加更详细的日志，看看到底哪一步出错了。

### 3.1 修改 LoginView.swift

在 `handleAppleSignIn` 方法开头添加：

```swift
private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
    print("🍎 [DEBUG] Apple Sign In 开始处理")
    
    switch result {
    case .success(let authorization):
        print("🍎 [DEBUG] ASAuthorization 成功")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ [DEBUG] 无法转换为 ASAuthorizationAppleIDCredential")
            return
        }
        
        print("🍎 [DEBUG] 获取到 credential")
        print("🍎 [DEBUG] user: \(appleIDCredential.user)")
        print("🍎 [DEBUG] fullName: \(String(describing: appleIDCredential.fullName))")
        print("🍎 [DEBUG] email: \(String(describing: appleIDCredential.email))")
        
        // ... 后续代码
        
    case .failure(let error):
        print("❌ [DEBUG] Apple Sign In 失败")
        print("❌ [DEBUG] Error domain: \(error._domain)")
        print("❌ [DEBUG] Error code: \(error._code)")
        print("❌ [DEBUG] Error: \(error.localizedDescription)")
        
        // ... 后续代码
    }
}
```

### 3.2 修改 AppleSignInButton.swift

在 `performSignIn` 方法中添加：

```swift
private func performSignIn() {
    print("🍎 [DEBUG] 准备开始 Apple Sign In")
    
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    
    print("🍎 [DEBUG] 创建 request")
    onRequest(request)
    print("🍎 [DEBUG] requestedScopes: \(String(describing: request.requestedScopes))")
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    
    print("🍎 [DEBUG] 创建 authorizationController")
    // ... 后续代码
    
    print("🍎 [DEBUG] 调用 performRequests()")
    authorizationController.performRequests()
}
```

---

## 🔍 第四步：运行并查看日志

### 4.1 清理并重新构建
```
1. Xcode 菜单: Product -> Clean Build Folder (Shift + Cmd + K)
2. 关闭 Xcode
3. 删除 DerivedData:
   rm -rf ~/Library/Developer/Xcode/DerivedData
4. 重新打开 Xcode
5. 运行项目
```

### 4.2 打开完整日志

在 Xcode 底部的 Console 中，确保看到：
```
🍎 [DEBUG] 准备开始 Apple Sign In
🍎 [DEBUG] 创建 request
...
```

### 4.3 关键日志检查

#### 如果看到：
```
🍎 [DEBUG] 准备开始 Apple Sign In
🍎 [DEBUG] 创建 request
🍎 [DEBUG] 调用 performRequests()
```
但之后没有任何输出 ❌

**说明**：`performRequests()` 根本没有触发系统认证
**原因**：Entitlements 或 Team 配置有问题

#### 如果看到：
```
❌ [DEBUG] Apple Sign In 失败
❌ [DEBUG] Error domain: AKAuthenticationError
❌ [DEBUG] Error code: -7071
```

**说明**：系统认证被触发了，但 Apple ID 认证失败
**原因**：真机 Apple ID 有问题

---

## 💡 第五步：终极解决方案

如果以上都不行，尝试以下"暴力"方案：

### 方案 A：重置真机
```
1. 设置 -> [你的名字] -> 退出登录
2. 重启手机
3. 设置 -> 登录 iPhone -> 重新登录 Apple ID
4. 确保开启双重认证
5. 重新运行 App
```

### 方案 B：重置 Xcode 配置
```
1. Xcode -> Preferences -> Accounts
2. 选择你的 Apple ID -> 点击 "-" 删除
3. 关闭 Xcode
4. 删除:
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf ~/Library/Developer/Xcode/UserData
5. 重新打开 Xcode
6. Preferences -> Accounts -> 点击 "+" 重新添加 Apple ID
7. 等待账号同步完成
8. 重新配置项目的 Team
9. 重新运行
```

### 方案 C：创建新的 Bundle ID
```
1. 在 Apple Developer 网站上创建新的 App ID:
   com.shanhai.poetry2 (或其他名称)
2. 启用 "Sign in with Apple" 能力
3. 在 Xcode 中修改 Bundle Identifier
4. 修改代码中的 SupabaseConfig (如果需要)
5. 重新运行
```

---

## 📊 常见错误码对照表

| 错误码 | 含义 | 解决方案 |
|-------|------|---------|
| -7071 | 认证服务不可用 | 检查 Apple ID / 双重认证 |
| 1000 | 通用认证错误 | 检查配置 / 网络 |
| 1001 | 用户取消 | 正常情况，用户点击了取消 |
| 1004 | 认证失败 | Bundle ID 或 Team 配置错误 |

---

## 🎯 下一步

1. **保存 Apple Developer 配置**（点击你截图中的 "Save"）
2. **在 Xcode 中检查 Team 配置**
3. **添加详细日志**（按照第三步）
4. **重新运行 App，查看日志输出**
5. **把日志发给我**，我帮你分析

如果还是不行，我们可以：
- 暂时使用测试模式（不连接后端）
- 或者考虑其他登录方式（虽然你不想用邮箱😅）

