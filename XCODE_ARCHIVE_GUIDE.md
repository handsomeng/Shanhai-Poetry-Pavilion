# 📦 Xcode Archive 和上传到 App Store Connect 详细指南

## 🎯 目标
将 **山海诗馆** 应用打包并上传到 App Store Connect

---

## ✅ 第一步：检查项目配置（5分钟）

### 1. 打开项目
在 Xcode 中打开：
```
/Users/handsomeng/Downloads/vibe-coding/BetweenLines/BetweenLines/BetweenLines.xcodeproj
```

### 2. 选择项目文件
- 在左侧导航栏点击最顶部的 **蓝色项目图标**（BetweenLines）

### 3. 检查 General 设置

点击 **General** 标签，确认以下信息：

| 字段 | 应该是 |
|------|--------|
| **Display Name** | 山海诗馆 |
| **Bundle Identifier** | com.shanhai.poetry |
| **Version** | 1.0.0 |
| **Build** | 1 |
| **Minimum Deployments** | iOS 16.0 或更高 |

### 4. 检查 Signing & Capabilities

点击 **Signing & Capabilities** 标签：

**✅ 必须配置：**
- [x] **Team**：选择你的 Apple Developer 账号
- [x] **Signing Certificate**：Apple Distribution（自动管理会自动选择）
- [x] **Provisioning Profile**：建议选择 **"Automatically manage signing"**

**✅ 必需的 Capabilities：**
- [x] **Sign in with Apple**
- [x] **iCloud**
  - [x] Key-value storage

**如果缺少 Capabilities，点击 "+ Capability" 添加**

---

## 🔨 第二步：选择构建目标（1分钟）

### 在 Xcode 顶部工具栏：

1. 找到设备选择器（通常在 Run 按钮旁边）
2. 点击下拉菜单
3. 选择 **"Any iOS Device (arm64)"**

⚠️ **重要**：不要选择模拟器，必须选择 "Any iOS Device"

---

## 🧹 第三步：清理构建（1分钟）

### 清理旧的构建文件：

**方法 1：菜单操作**
```
Product → Clean Build Folder
```
或按快捷键：`Shift + Cmd + K`

**方法 2：手动删除 DerivedData**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

---

## 📦 第四步：Archive（5-10分钟）

### 1. 开始 Archive

**菜单操作：**
```
Product → Archive
```

⚠️ **注意**：如果 "Archive" 选项是灰色的，说明：
- 你选择的是模拟器，而不是 "Any iOS Device"
- 或者项目有编译错误

### 2. 等待构建完成

- 构建过程需要 5-10 分钟
- 顶部会显示进度条
- 如果有错误，会在底部显示

### 3. Archive 成功

构建成功后，**Organizer** 窗口会自动打开，显示你的 Archive

---

## 📤 第五步：上传到 App Store Connect（5-10分钟）

### 1. 在 Organizer 中

如果 Organizer 没有自动打开：
```
Window → Organizer
```

### 2. 选择 Archive

- 在左侧选择 **"Archives"** 标签
- 选择 **"BetweenLines"** 应用
- 选择刚才创建的 Archive（最新的，在最顶部）

### 3. 点击 "Distribute App"

在右侧点击蓝色按钮 **"Distribute App"**

### 4. 选择分发方式

选择 **"App Store Connect"**，点击 **"Next"**

### 5. 选择上传方式

选择 **"Upload"**，点击 **"Next"**

### 6. 配置选项

**Distribution options**：
- [x] Upload your app's symbols to receive symbolicated reports from Apple
- [x] Manage Version and Build Number (Xcode 管理版本号)

点击 **"Next"**

### 7. 自动签名

Xcode 会自动处理签名，点击 **"Next"**

### 8. 确认并上传

- 检查应用信息
- 点击 **"Upload"**

### 9. 等待上传完成

- 上传需要 5-10 分钟（取决于网络速度）
- 上传完成后会显示成功提示

---

## ⏱️ 第六步：等待处理（5-30分钟）

### 上传后的处理流程：

1. **上传完成**：Xcode 显示成功
2. **处理中**：App Store Connect 处理你的构建版本
3. **可用**：构建版本出现在 App Store Connect 中

### 如何查看处理状态：

1. 访问 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **"我的 App"** → **"山海诗馆"**
3. 点击左侧 **"TestFlight"** 标签
4. 查看 **"iOS 构建版本"** 部分

**状态说明：**
- 🟡 **处理中**：正在处理，需要等待
- 🟢 **可供测试**：处理完成，可以使用了

---

## ✅ 第七步：在 App Store Connect 中配置版本

### 1. 添加新版本

1. 在 App Store Connect 中，进入 **"山海诗馆"**
2. 点击左侧 **"App Store"** 标签
3. 点击版本号旁边的 **"+"** 按钮
4. 输入版本号：**1.0.0**
5. 点击 **"创建"**

### 2. 选择构建版本

在 **"构建版本"** 部分：
- 点击 **"+"** 或 **"选择构建版本"**
- 选择刚才上传的构建版本（1.0.0, Build 1）
- 如果没有显示，等待几分钟后刷新页面

### 3. 填写版本信息

**此版本的新功能**（复制以下内容）：

```
🎉 山海诗馆 1.0 正式发布！

【核心功能】

📚 学诗模块
• 6 大主题，20+ 篇原创教程
• 系统化学习现代诗创作

✍️ 写诗模块
• 直接写诗：自由创作
• 模仿写诗：参考经典
• 主题写诗：AI 辅助灵感

🤖 AI 智能点评
• 四维度分析：意象、情感、语言、结构
• 专业建议，快速提升

🌸 赏诗模块
• 浏览优秀作品
• 最新、热门、随机筛选

👤 我的模块
• 作品管理：已发布、草稿、收藏
• 数据统计：作品数、获赞数
• iCloud 同步，多设备无缝切换

【设计特色】
• 极简美学，Dribbble 级别设计
• 优雅排版，专注创作体验
• 数据安全，保护隐私

感谢支持！让我们一起用诗歌记录生活 ✨
```

### 4. 上传截图

在 **"App 预览和截图"** 部分：
- 选择 **"6.7" Display"**（iPhone 15 Pro Max）
- 点击 **"+"** 上传截图
- 至少上传 1 张，建议 6-8 张

**如果还没有截图**：
1. 在 Xcode 中运行应用到 iPhone 15 Pro Max 模拟器
2. 导航到各个页面
3. 按 `Cmd + S` 保存截图（自动保存到桌面）

### 5. 填写其他必填信息

确保以下信息已填写（在 App 信息页面）：
- [x] App 名称：山海诗馆
- [x] 副标题：现代诗创作与分享
- [x] 描述（从 `APP_STORE_DESCRIPTION.txt` 复制）
- [x] 关键词
- [x] 支持 URL：https://www.handsomeng.com
- [x] 隐私政策 URL（你的 GitHub raw 链接）
- [x] 类别：生活 / 娱乐
- [x] 年龄分级：4+

---

## 🚀 第八步：提交审核

### 1. 检查清单

在提交前，确认：
- [x] 构建版本已选择
- [x] 截图已上传
- [x] 所有必填信息已填写
- [x] 隐私政策 URL 可以访问
- [x] App Review 信息已填写

### 2. 提交

1. 点击右上角 **"存储"**
2. 点击 **"提交以供审核"**
3. 回答出口合规性问题：
   - **是否使用加密**：是（HTTPS）
   - **是否符合美国出口法规**：是
4. 点击 **"提交"**

---

## 🎉 完成！

### 审核时间线：

- **提交成功**：立即
- **等待审核**：1-3 天（通常）
- **审核中**：几小时到 1 天
- **审核结果**：
  - ✅ **批准**：可以上线了！
  - ❌ **被拒**：查看原因，修改后重新提交

### 查看审核状态：

在 App Store Connect 中：
- **"准备提交"**：还没提交
- **"正在等待审核"**：已提交，排队中
- **"正在审核"**：审核人员正在测试
- **"准备销售"**：审核通过，可以上线
- **"被拒绝"**：需要修改

---

## 🚨 常见问题

### Q1: Archive 选项是灰色的？
**A**: 确保选择了 "Any iOS Device (arm64)"，而不是模拟器

### Q2: 签名失败？
**A**: 
1. 检查 Team 是否选择正确
2. 确保开发者账号有效
3. 尝试 "Automatically manage signing"

### Q3: 构建版本在 App Store Connect 中不显示？
**A**: 等待 5-30 分钟，Apple 需要处理时间

### Q4: 上传失败？
**A**:
1. 检查网络连接
2. 检查 Apple Developer 账号状态
3. 尝试重新 Archive

### Q5: 审核被拒？
**A**: 查看拒绝原因，常见原因：
- 隐私政策 URL 无法访问
- Sign in with Apple 未正确配置
- 应用崩溃或有明显 Bug
- 描述与实际功能不符

---

## 📞 需要帮助？

如果遇到问题：
1. 查看 Xcode 的错误信息
2. 查看 App Store Connect 的拒绝原因
3. 联系 Apple 开发者支持

---

## ✅ 快速检查清单

**Archive 前：**
- [ ] 选择 "Any iOS Device (arm64)"
- [ ] 版本号和构建号正确
- [ ] Signing & Capabilities 配置正确
- [ ] 清理了构建文件夹

**上传前：**
- [ ] Archive 成功
- [ ] 在 Organizer 中可以看到 Archive
- [ ] 网络连接正常

**提交审核前：**
- [ ] 构建版本已选择
- [ ] 截图已上传（至少 1 张）
- [ ] 所有必填信息已填写
- [ ] 隐私政策 URL 可以访问
- [ ] 在真机上测试过，无崩溃

---

**祝你成功上传！** 🚀

如有任何问题，随时询问！

---

**最后更新**：2025年10月24日

