//
//  TemplateSelector.swift
//  山海诗馆
//
//  模板选择器：全屏展示，实时预览
//

import SwiftUI

struct TemplateSelector: View {
    
    @Binding var selectedTemplate: PoemTemplateType
    @Environment(\.dismiss) private var dismiss
    let poem: Poem
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 主视觉区域：实时预览（占据大部分空间）
                ScrollView {
                    selectedTemplate.render(
                        poem: poem,
                        size: CGSize(width: 340, height: 0)
                    )
                    .padding(.vertical, Spacing.xl)
                }
                .background(Colors.backgroundCream)
                
                // 模板卡片列表（紧凑区域）
                templateCardsList
                
                // 确认按钮（紧凑区域）
                confirmButton
            }
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Colors.textInk)
                    }
                }
            }
        }
    }
    
    // MARK: - Template Cards List
    
    private var templateCardsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PoemTemplateType.allCases) { type in
                    TemplateCard(
                        template: type,
                        isSelected: selectedTemplate == type,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTemplate = type
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .frame(height: 120) // 紧凑的高度
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(hex: "E5E5E5")),
            alignment: .top
        )
    }
    
    // MARK: - Confirm Button
    
    private var confirmButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("确认")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Colors.accentTeal)
                .cornerRadius(12)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .background(Color.white)
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: PoemTemplateType
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // 模板图标
                Text(template.icon)
                    .font(.system(size: 32))
                
                // 模板名称
                Text(template.rawValue)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Colors.textInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 90, height: 90)
            .background(isSelected ? Colors.accentTeal.opacity(0.05) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Colors.accentTeal : Color(hex: "E5E5E5"),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Preview

#Preview {
    TemplateSelector(
        selectedTemplate: .constant(.lovartMinimal),
        poem: Poem(
            title: "夜思",
            content: "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡",
            authorName: "诗人",
            tags: [],
            writingMode: .direct
        )
    )
}

