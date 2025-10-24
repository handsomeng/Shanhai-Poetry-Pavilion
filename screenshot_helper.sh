#!/bin/bash

# App Store 截图助手
# 自动将截图调整为 App Store 要求的尺寸

echo "════════════════════════════════════════════════"
echo "📱 App Store 截图助手"
echo "════════════════════════════════════════════════"
echo ""

# 检查是否有 sips 命令（macOS 自带）
if ! command -v sips &> /dev/null; then
    echo "❌ 错误：sips 命令不可用"
    exit 1
fi

# 目标尺寸（6.5" Display）
TARGET_WIDTH=1242
TARGET_HEIGHT=2688

# 创建输出目录
OUTPUT_DIR="$HOME/Desktop/AppStore_Screenshots_6.5"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "📂 输出目录：$OUTPUT_DIR"
echo "📱 目标尺寸：${TARGET_WIDTH} x ${TARGET_HEIGHT} (6.5\" Display)"
echo ""

# 查找桌面上的所有 PNG 截图（排除输出目录）
echo "🔍 正在查找桌面上的截图..."
SCREENSHOTS=$(find ~/Desktop -maxdepth 1 -name "*.png" -not -path "$OUTPUT_DIR/*" 2>/dev/null)

if [ -z "$SCREENSHOTS" ]; then
    echo "❌ 未找到截图文件"
    echo ""
    echo "💡 请先在模拟器中截图（Cmd + S）"
    echo "   或使用真机截图后传到桌面"
    echo ""
    echo "📂 查找位置：$HOME/Desktop/*.png"
    exit 1
fi

# 显示找到的文件
echo "✅ 找到以下截图文件："
echo "$SCREENSHOTS" | while read -r file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "   • $filename"
    fi
done
echo ""

# 计数器
COUNT=0

# 处理每个截图
echo "🎨 开始处理截图..."
echo ""

echo "$SCREENSHOTS" | while read -r file; do
    if [ -f "$file" ]; then
        COUNT=$((COUNT + 1))
        filename=$(basename "$file")
        output_file="$OUTPUT_DIR/appstore_screenshot_$COUNT.png"
        
        echo "[$COUNT] 处理：$filename"
        
        # 获取当前尺寸
        current_width=$(sips -g pixelWidth "$file" | grep pixelWidth | awk '{print $2}')
        current_height=$(sips -g pixelHeight "$file" | grep pixelHeight | awk '{print $2}')
        
        echo "    当前尺寸：${current_width} x ${current_height}"
        
        # 检查尺寸是否已经正确
        if [ "$current_width" -eq "$TARGET_WIDTH" ] && [ "$current_height" -eq "$TARGET_HEIGHT" ]; then
            echo "    ✅ 尺寸正确，直接复制"
            cp "$file" "$output_file"
        else
            echo "    🔧 调整为：${TARGET_WIDTH} x ${TARGET_HEIGHT}"
            
            # 使用 sips 调整尺寸（保持比例，裁剪或填充）
            # 先缩放到目标高度
            sips -Z $TARGET_HEIGHT "$file" --out "$output_file" > /dev/null 2>&1
            
            # 然后裁剪宽度（居中）
            sips -z $TARGET_HEIGHT $TARGET_WIDTH "$output_file" > /dev/null 2>&1
            
            echo "    ✅ 已保存：appstore_screenshot_$COUNT.png"
        fi
        echo ""
    fi
done

# 统计处理的文件数量
TOTAL_COUNT=$(echo "$SCREENSHOTS" | wc -l | tr -d ' ')

echo "════════════════════════════════════════════════"
echo "✅ 完成！共处理 $TOTAL_COUNT 张截图"
echo "════════════════════════════════════════════════"
echo ""
echo "📂 截图位置：$OUTPUT_DIR"
echo ""
echo "📱 尺寸：${TARGET_WIDTH} x ${TARGET_HEIGHT} (6.5\" Display)"
echo ""
echo "🚀 现在可以上传到 App Store Connect 了！"
echo ""
echo "💡 上传步骤："
echo "   1. 在 App Store Connect 中选择 '6.5\" Display'"
echo "   2. 点击 '+' 上传截图"
echo "   3. 选择 $OUTPUT_DIR 中的截图"
echo "   4. 按顺序排列（screenshot_1, 2, 3...）"
echo ""
echo "📝 注意：App Store 接受的 6.5\" 尺寸："
echo "   • 1242 x 2688 (竖屏) ✅"
echo "   • 2688 x 1242 (横屏)"
echo "   • 1284 x 2778 (新款)"
echo "   • 2778 x 1284 (新款横屏)"
echo ""
