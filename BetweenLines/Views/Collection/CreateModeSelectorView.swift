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
    @State private var navigateToMode: WritingMode? = nil
    
    enum WritingMode: Identifiable {
        case theme, mimic, direct
        
        var id: String {
            switch self {
            case .theme: return "theme"
            case .mimic: return "mimic"
            case .direct: return "direct"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Text("选择写诗模式")
                    .font(Fonts.titleMedium())
                    .foregroundColor(Colors.textInk)
                    .padding(.top, Spacing.xl)
                
                // 主题写诗
                ModeButton(
                    icon: "🎨",
                    title: "主题写诗",
                    subtitle: "AI 给你灵感主题",
                    action: { navigateToMode = .theme }
                )
                
                // 临摹写诗
                ModeButton(
                    icon: "🖼️",
                    title: "临摹写诗",
                    subtitle: "模仿经典诗词风格",
                    action: { navigateToMode = .mimic }
                )
                
                // 直接写诗
                ModeButton(
                    icon: "✍️",
                    title: "直接写诗",
                    subtitle: "自由发挥创作",
                    action: { navigateToMode = .direct }
                )
                
                Spacer()
                
                // 取消按钮
                Button("取消") {
                    dismiss()
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .padding(.bottom, Spacing.xl)
            }
            .padding(.horizontal, Spacing.xl)
            .background(Colors.backgroundCream)
            .navigationDestination(item: $navigateToMode) { mode in
                switch mode {
                case .theme:
                    ThemeWritingView()
                case .mimic:
                    MimicWritingView()
                case .direct:
                    DirectWritingView()
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Mode Button

struct ModeButton: View {
    
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Text(icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Fonts.bodyLargeBold())
                        .foregroundColor(Colors.textInk)
                    
                    Text(subtitle)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textTertiary)
            }
            .padding(Spacing.md)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Preview

#Preview {
    CreateModeSelectorView()
}

