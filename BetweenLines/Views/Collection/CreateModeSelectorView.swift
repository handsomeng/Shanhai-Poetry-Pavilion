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
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
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
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xxl)
            }
            .background(Colors.backgroundCream)
            .navigationTitle("选择写诗模式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
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
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 顶部：图标和标题
                HStack(spacing: Spacing.lg) {
                    // 图标背景圆形
                    ZStack {
                        Circle()
                            .fill(Colors.accentTeal.opacity(0.1))
                            .frame(width: 64, height: 64)
                        
                        Text(icon)
                            .font(.system(size: 32))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundColor(Colors.textInk)
                        
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Colors.textTertiary)
                }
                
                // 描述文字
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(Colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
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

