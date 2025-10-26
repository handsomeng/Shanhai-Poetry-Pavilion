//
//  CreateModeSelectorView.swift
//  山海诗馆
//
//  创作模式选择器
//  - 从底部弹出的半屏弹窗
//  - 三种创作模式：主题写诗、临摹写诗、直接写诗
//

import SwiftUI

struct CreateModeSelectorView: View {
    
    @Environment(\.dismiss) private var dismiss
    let onSelectMode: (WritingMode) -> Void
    
    enum WritingMode {
        case theme, mimic, direct
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            Text("选择写诗模式")
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.lg)
            
            // 卡片列表
            VStack(spacing: Spacing.md) {
                // 主题写诗
                ModeCard(
                    icon: "🎨",
                    title: "主题写诗",
                    subtitle: "AI 给你灵感主题",
                    description: "让 AI 为你生成创作主题，激发灵感",
                    action: {
                        onSelectMode(.theme)
                        dismiss()
                    }
                )
                
                // 临摹写诗
                ModeCard(
                    icon: "🖼️",
                    title: "临摹写诗",
                    subtitle: "模仿经典诗词风格",
                    description: "学习古典诗词的韵律与意境",
                    action: {
                        onSelectMode(.mimic)
                        dismiss()
                    }
                )
                
                // 直接写诗
                ModeCard(
                    icon: "✍️",
                    title: "直接写诗",
                    subtitle: "自由发挥创作",
                    description: "随心所欲，记录此刻的心情与感悟",
                    action: {
                        onSelectMode(.direct)
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, Spacing.lg)
            
            Spacer()
            
            // 取消按钮
            Button("取消") {
                dismiss()
            }
            .font(Fonts.bodyRegular())
            .foregroundColor(Colors.textSecondary)
            .padding(.bottom, 50)  // 增加底部间距，避免被 Tab 挡住
        }
        .background(Colors.backgroundCream)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Mode Card

struct ModeCard: View {
    
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // 图标背景圆形
                ZStack {
                    Circle()
                        .fill(Colors.accentTeal.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundColor(Colors.textInk)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Colors.textTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Preview

#Preview {
    CreateModeSelectorView { mode in
        print("Selected mode: \(mode)")
    }
}

