//
//  PoetProfileView.swift
//  山海诗馆
//
//  AI 诗人画像分析视图（隐藏彩蛋）
//

import SwiftUI

struct PoetProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    let profileText: String
    let isLoading: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 标题区域
                        headerSection
                        
                        // 分析内容
                        if isLoading {
                            loadingView
                        } else {
                            contentSection
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xl)
                }
            }
            .navigationTitle("诗人画像")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(Colors.accentTeal)
            
            Text("AI 为你解读")
                .font(Fonts.h2())
                .foregroundColor(Colors.textInk)
            
            Text("基于你最近的创作分析")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
    
    // MARK: - Loading
    
    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Colors.accentTeal)
            
            Text("AI 正在阅读你的诗...")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
    
    // MARK: - Content
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(profileText)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(Colors.textInk)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .padding(.vertical, Spacing.sm)
            
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
                
                Text("这是一个隐藏彩蛋功能，连续点击 5 次「诗集」标题即可触发")
                    .font(.system(size: 13))
                    .foregroundColor(Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    PoetProfileView(
        profileText: "你是一位细腻的观察者，喜欢捕捉生活中的微小瞬间。你的诗歌充满了对自然的热爱和对人生的思考...",
        isLoading: false
    )
}

