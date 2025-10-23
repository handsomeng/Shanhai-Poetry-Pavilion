# 🚀 快速调试步骤

## 第一步：保存 Apple Developer 配置

✅ 在你刚才的截图中，点击 **"Save"** 按钮

---

## 第二步：清理并重新构建

在终端运行：
```bash
cd /Users/handsomeng/Downloads/vibe-coding/BetweenLines/BetweenLines
rm -rf ~/Library/Developer/Xcode/DerivedData
```

然后在 Xcode 中：
```
1. Product -> Clean Build Folder (Shift + Cmd + K)
2. 关闭 Xcode
3. 重新打开 Xcode
4. 运行项目到真机
```

---

## 第三步：查看详细日志

现在点击 "使用 Apple 登录" 按钮，观察 Console 的输出。

### ✅ 正常情况（应该看到）：

```
🍎 [DEBUG] ===== 准备开始 Apple Sign In =====
✅ [DEBUG] 创建 ASAuthorizationAppleIDProvider
✅ [DEBUG] 创建 request
✅ [DEBUG] requestedScopes: Optional([...])
✅ [DEBUG] 创建 ASAuthorizationController
🚀 [DEBUG] 调用 performRequests()...
✅ [DEBUG] performRequests() 已调用
```

然后会弹出 Apple 登录窗口 → 认证成功后：

```
✅ [DEBUG] Coordinator: 收到授权成功回调
🍎 [DEBUG] ===== Apple Sign In 回调触发 =====
✅ [DEBUG] ASAuthorization 成功
✅ [DEBUG] 获取到 credential
🆔 [DEBUG] user: xxx
📧 [DEBUG] email: Optional(...)
👤 [DEBUG] fullName: Optional(...)
🔑 [DEBUG] identityToken: 存在
🍎 [DEBUG] 开始调用 authService.signInWithApple...
✅ [DEBUG] Apple 登录成功！用户：xxx
🚪 准备关闭登录界面...
```

---

### ❌ 异常情况 1：没有弹窗

如果你看到：
```
🍎 [DEBUG] ===== 准备开始 Apple Sign In =====
...
✅ [DEBUG] performRequests() 已调用
```

**之后没有任何输出，也没有弹窗**

**原因**：
- Entitlements 配置有问题
- Team 配置有问题
- Bundle ID 和 Apple Developer 不匹配

**解决方案**：
1. 在 Xcode 中，检查 `Signing & Capabilities` 标签
2. 确保 "Sign in with Apple" 能力存在
3. 确保 Team 不是 "None"
4. 尝试删除并重新添加 "Sign in with Apple" 能力

---

### ❌ 异常情况 2：弹窗后报错

如果你看到：
```
✅ [DEBUG] performRequests() 已调用
❌ [DEBUG] Coordinator: 收到授权失败回调
❌ [DEBUG] Coordinator: Error domain: AKAuthenticationError
❌ [DEBUG] Coordinator: Error code: -7071
```

**原因**：
- 真机未登录 Apple ID
- 双重认证未开启
- Apple ID 账号异常

**解决方案**：
1. 退出真机上的 Apple ID
2. 重启真机
3. 重新登录 Apple ID
4. 确保开启双重认证
5. 重新运行 App

---

### ❌ 异常情况 3：认证成功但后续失败

如果你看到：
```
✅ [DEBUG] 获取到 credential
🔑 [DEBUG] identityToken: 存在
🍎 [DEBUG] 开始调用 authService.signInWithApple...
❌ Apple 登录失败：xxx
```

**原因**：
- Supabase 配置有问题
- 网络连接问题
- identityToken 验证失败

**解决方案**：
1. 检查 Supabase Apple 登录配置
2. 检查 Bundle ID 是否匹配
3. 查看完整的错误信息

---

## 第四步：把日志发给我

无论是什么情况，把 Console 的完整日志**复制发给我**，我会帮你分析！

需要的日志从这行开始：
```
🍎 [DEBUG] ===== 准备开始 Apple Sign In =====
```

到最后的结果（成功或失败）。

---

## 💡 快速检查清单

在运行前，确认：

- [ ] Apple Developer 配置已保存（点击 Save）
- [ ] 真机已登录 Apple ID
- [ ] 双重认证已开启
- [ ] Xcode 中 Team 不是 "None"
- [ ] Xcode 中有 "Sign in with Apple" 能力
- [ ] 已清理 DerivedData
- [ ] 重新构建项目

全部确认后，运行并观察日志！🚀

