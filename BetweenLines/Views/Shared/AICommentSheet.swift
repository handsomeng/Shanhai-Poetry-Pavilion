//
//  AICommentSheet.swift
//  山海诗馆
//
//  AI 点评展示页面
//

import SwiftUI

struct AICommentSheet: View {
    
    let comment: String
    let isLoading: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else {
                    commentView
                }
            }
            .navigationTitle("AI 诗评")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        onDismiss()
                    }
                    .foregroundColor(Colors.accentTeal)
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Colors.accentTeal)
            
            Text("AI 正在认真阅读你的诗...")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Comment View
    
    private var commentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // AI 图标和标题
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 0.9),
                                        Color(red: 0.5, green: 0.5, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI 诗评")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Colors.textInk)
                        
                        Text("专业、客观、真诚")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // 点评内容
                VStack(alignment: .leading, spacing: 16) {
                    Text(comment)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Colors.textInk)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 提示文字
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Colors.accentTeal.opacity(0.6))
                        
                        Text("AI点评仅供参考，相信自己的感受最重要")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(Colors.white)
                .cornerRadius(CornerRadius.large)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
}

// MARK: - Preview

#Preview("加载中") {
    AICommentSheet(
        comment: "",
        isLoading: true,
        onDismiss: {}
    )
}

#Preview("点评内容") {
    AICommentSheet(
        comment: "这首诗通过简洁的意象，捕捉了一个宁静的瞬间。「月光」和「霜」的对比营造出清冷的氛围，「望」与「思」两个动作串联起内心的情感流动。语言凝练，情感真挚。\n\n建议：可以尝试在分行上做更多变化，让节奏更有层次感。另外，「故乡」这个词略显常规，可以考虑用更具体的意象来代替，会让诗更有个人色彩。",
        isLoading: false,
        onDismiss: {}
    )
}

