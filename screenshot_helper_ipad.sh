#!/bin/bash

# App Store iPad 截图助手
# 自动将 iPad 截图调整为 App Store 要求的尺寸

echo "════════════════════════════════════════════════"
echo "📱 App Store iPad 截图助手"
echo "════════════════════════════════════════════════"
echo ""

# 检查是否有 sips 命令（macOS 自带）
if ! command -v sips &> /dev/null; then
    echo "❌错误：sips 命令不可用"
    exit 1
fi

# iPad Pro 13 存 目标尺寸
TARGET_WIDTH=2064
TARGET_HEIGHT=2752

# 创建输出目录
OUTPUT_DIR="$HOME/Desktop/AppStore_Screenshots_iPad"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "📂 输出目录：$OUTPUT_DIR"
echo "📱 目标尺寸：${TARGET_WIDTH} x ${TARGET_HEIGHT} (iPad Pro 13 存 竖屏)"
echo ""

# 查找桌面上的所有 PNG 截图（排除输出目录）
echo "🔍 正在查找桌面上的截图..."
SCREENSHOTS=$(find ~/Desktop -maxdepth 1 -name "*.png" -not -path "$OUTPUT_DIR/*" 2>/dev/null)

if [ -z "$SCREENSHOTS" ]; then
    echo "❌ 未找到截图文件"
    echo ""
    echo "💡 请先在 iPad 模拟器中截图（Cmd + S）"
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
        output_file="$OUTPUT_DIR/appstore_screenshot_ipad_$COUNT.png"
        
        echo "[$COUNT] 处理：$filename"
        
        # 获取当前尺寸
        current_width=$(sips -g pixelWidth "$file" | grep pixelWidth | awk '{print $2}')
        current_height=$(sips -g pixelHeight "$file" | grep pixelHeight | awk '{print $2}')
        
        echo "    当前尺寸：${current_width} x ${current_height}"
        
        # 判断是横屏还是竖屏
        if [ "$current_width" -gt "$current_height" ]; then
            # 横屏：调整为 2752 x 2064
            FINAL_WIDTH=2752
            FINAL_HEIGHT=2064
            echo "    📐 检测到横屏"
        else
            # 竖屏：调整为 2064 x 2752
            FINAL_WIDTH=2064
            FINAL_HEIGHT=2752
            echo "    📐 检测到竖屏"
        fi
        
        # 检查尺寸是否已经正确
        if [ "$current_width" -eq "$FINAL_WIDTH" ] && [ "$current_height" -eq "$FINAL_HEIGHT" ]; then
            echo "    ✅ 尺寸正确，直接复制"
            cp "$file" "$output_file"
        else
            echo "    🔧 调整为：${FINAL_WIDTH} x ${FINAL_HEIGHT}"
            
            # 计算缩放比例
            width_ratio=$(echo "scale=4; $FINAL_WIDTH / $current_width" | bc)
            height_ratio=$(echo "scale=4; $FINAL_HEIGHT / $current_height" | bc)
            
            # 使用较大的比例以填充目标尺寸
            if (( $(echo "$width_ratio > $height_ratio" | bc -l) )); then
                scale_ratio=$width_ratio
            else
                scale_ratio=$height_ratio
            fi
            
            # 计算缩放后的尺寸
            scaled_width=$(echo "scale=0; $current_width * $scale_ratio" | bc | cut -d. -f1)
            scaled_height=$(echo "scale=0; $current_height * $scale_ratio" | bc | cut -d. -f1)
            
            # 先缩放
            sips -z $scaled_height $scaled_width "$file" --out "$output_file" > /dev/null 2>&1
            
            # 再裁剪到目标尺寸（居中裁剪）
            sips -z $FINAL_HEIGHT $FINAL_WIDTH "$output_file" > /dev/null 2>&1
            
            echo "    ✅ 已保存：appstore_screenshot_ipad_$COUNT.png"
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
echo "📱 支持的尺寸："
echo "   • 2064 x 2752 (竖屏) ✅"
echo "   • 2752 x 2064 (横屏) ✅"
echo "   • 2048 x 2732 (旧款竖屏)"
echo "   • 2732 x 2048 (旧款横屏)"
echo ""
echo "🚀 现在可以上传到 App Store Connect 了！"
echo ""
echo "💡 上传步骤："
echo "   1. 在 App Store Connect 中选择 'iPad Pro (第 3 代) 12.9 存'"
echo "   2. 点击 '+' 上传截图"
echo "   3. 选择 $OUTPUT_DIR 中的截图"
echo "   4. 按顺序排列"
echo ""

