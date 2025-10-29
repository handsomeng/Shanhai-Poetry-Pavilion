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
    
    @State private var showingLearning = false
    
    enum WritingMode {
        case theme, mimic, direct
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // 顶部留白，让卡片整体往下
                Spacer()
                    .frame(height: 40)
                
                // 主题写诗
                ModeCard(
                    icon: "🎨",
                    title: "主题写诗",
                    description: "为你推荐创作的主题",
                    action: {
                        onSelectMode(.theme)
                        dismiss()
                    }
                )
                
                // 临摹写诗
                ModeCard(
                    icon: "🖼️",
                    title: "临摹写诗",
                    description: "从模仿入手开始创作",
                    action: {
                        onSelectMode(.mimic)
                        dismiss()
                    }
                )
                
                // 直接写诗
                ModeCard(
                    icon: "✍️",
                    title: "直接写诗",
                    description: "随心所欲，自由创作",
                    action: {
                        onSelectMode(.direct)
                        dismiss()
                    }
                )
                
                // "了解现代诗" 文字链接（紧跟卡片）
                Button(action: {
                    showingLearning = true
                }) {
                    Text("了解现代诗")
                        .font(.footnote)
                        .foregroundColor(Colors.textSecondary)
                        .underline()
                }
                .padding(.top, Spacing.lg)
                
                // 底部灵活留白
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xl)
            .frame(maxHeight: .infinity)
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
        .fullScreenCover(isPresented: $showingLearning) {
            NavigationStack {
                LearningView()
            }
        }
    }
}

// MARK: - Mode Card

struct ModeCard: View {
    
    let icon: String
    let title: String
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
                        .frame(width: 52, height: 52)
                    
                    Text(icon)
                        .font(.system(size: 26))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundColor(Colors.textInk)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.textTertiary)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
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

