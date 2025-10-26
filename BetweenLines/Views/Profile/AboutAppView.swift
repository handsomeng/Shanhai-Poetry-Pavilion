//
//  AboutAppView.swift
//  BetweenLines - 山海诗馆
//
//  关于山海诗馆页面
//

import SwiftUI

struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Logo/Icon
                VStack(spacing: 16) {
                    // App图标
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Colors.accentTeal,
                                        Colors.accentTeal.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("🏔️")
                            .font(.system(size: 50))
                    }
                    
                    // App名称
                    Text("山海诗馆")
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                    
                    Text("Between Lines")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                        .tracking(2)
                    
                    Text("版本 1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(Colors.textTertiary)
                }
                .padding(.top, 32)
                
                // 小小愿景
                infoCard(title: "小小愿景") {
                    Text("你好呀，欢迎来到山海诗馆。\n\n这是一款专为现代诗爱好者打造的写诗应用。\n\n作为一个普普通通的现代诗爱好者，从一点都不会写，到在 AI 的陪伴下慢慢写出 10 首，20首，100 首 …… 现代诗成为了我必不可少的生命力量之一。\n\n我也相信，诗歌不应该是高不可攀的艺术，每个人心中都有属于自己的山海。\n\n在这里，你可以自由创作，记录灵感，学习技巧，让诗歌成为生活的一部分。")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Colors.textInk)
                        .lineSpacing(6)
                }
                
                // 核心功能
                infoCard(title: "核心功能") {
                    VStack(alignment: .leading, spacing: 12) {
                        featureRow(icon: "✍️", title: "多种写诗模式", description: "主题、仿写、自由创作")
                        featureRow(icon: "📚", title: "系统学习", description: "从零开始学习诗歌创作")
                        featureRow(icon: "🎨", title: "精美模板", description: "一键生成分享图片")
                        featureRow(icon: "☁️", title: "iCloud同步", description: "所有设备无缝同步")
                    }
                }
                
                // 联系我们
                infoCard(title: "联系我们") {
                    VStack(spacing: 12) {
                        contactRow(
                            icon: "envelope",
                            text: "martinwm2011@hotmail.com",
                            url: "mailto:martinwm2011@hotmail.com"
                        )
                    }
                }
                
                // 版权信息
                Text("© 2025 山海诗馆. All rights reserved.")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.textTertiary)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
        .background(Colors.backgroundCream)
        .navigationTitle("关于山海诗馆")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 信息卡片
    
    @ViewBuilder
    private func infoCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            
            VStack(alignment: .leading, spacing: 0) {
                content()
                    .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - 功能行
    
    @ViewBuilder
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Colors.textInk)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 联系方式行
    
    @ViewBuilder
    private func contactRow(icon: String, text: String, url: String) -> some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Colors.accentTeal)
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(Colors.textInk)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Colors.accentTeal)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        AboutAppView()
    }
}

