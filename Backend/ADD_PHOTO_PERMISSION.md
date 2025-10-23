# 📸 添加相册权限说明

> 保存图片功能需要添加相册权限

---

## 方法：在Xcode项目设置中添加

### 步骤：

1. **打开Xcode项目**
   - 在左侧导航栏点击 `BetweenLines` 项目

2. **选择Target**
   - 选择 `BetweenLines` target

3. **进入Info标签**
   - 点击顶部的 `Info` 标签

4. **添加权限说明**
   - 点击 `Custom iOS Target Properties` 下的 `+` 按钮
   - 添加以下两个权限：

#### 权限1：NSPhotoLibraryAddUsageDescription
```
Key: Privacy - Photo Library Additions Usage Description
Value: 保存您创作的诗歌图片到相册
```

#### 权限2：NSPhotoLibraryUsageDescription
```
Key: Privacy - Photo Library Usage Description  
Value: 访问您的相册以保存诗歌图片
```

---

## 或者：使用命令行添加（推荐）

如果项目使用 `Info.plist` 文件，可以用命令行添加：

```bash
# 进入项目目录
cd BetweenLines

# 添加权限
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryAddUsageDescription string '保存您创作的诗歌图片到相册'" Info.plist
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string '访问您的相册以保存诗歌图片'" Info.plist
```

---

## 验证

添加后重新运行App，点击"保存图片"按钮时会弹出权限请求对话框。

---

**注意**：如果不添加这些权限说明，App会在请求相册权限时崩溃！

