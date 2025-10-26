//
//  AboutDeveloperView.swift
//  BetweenLines - 山海诗馆
//
//  关于开发者页面
//

import SwiftUI

struct AboutDeveloperView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 开发者头像/Logo
                    VStack(spacing: 16) {
                        // 开发者图标
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Colors.accentTeal.opacity(0.2),
                                            Colors.accentTeal.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Text("🧑‍💻")
                                .font(.system(size: 50))
                        }
                        
                        // 开发者名字
                        Text("HandsoMeng")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .foregroundColor(Colors.textInk)
                        
                        Text("独立开发者")
                            .font(.system(size: 14))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .padding(.top, 32)
                    
                    // 个人简介
                    infoCard(title: "关于我") {
                        Text("热爱诗歌，热爱编程。\n希望用技术让诗歌创作变得更简单、更有趣。\n山海诗馆是我送给所有诗歌爱好者的礼物。")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(Colors.textInk)
                            .lineSpacing(6)
                    }
                    
                    // 联系方式
                    infoCard(title: "联系我") {
                        VStack(spacing: 12) {
                            contactRow(
                                icon: "globe",
                                label: "个人网站",
                                value: "handsomeng.com",
                                url: "https://www.handsomeng.com"
                            )
                            
                            Divider()
                                .padding(.horizontal, 8)
                            
                            contactRow(
                                icon: "envelope",
                                label: "邮箱",
                                value: "hi@handsomeng.com",
                                url: "mailto:hi@handsomeng.com"
                            )
                        }
                    }
                    
                    // 特别感谢
                    infoCard(title: "特别感谢") {
                        Text("感谢 Cursor、Claude、DeepSeek\n以及所有使用山海诗馆的诗人们\n是你们让这个应用充满生命力")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(Colors.textInk)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 版权信息
                    Text("© 2025 HandsoMeng. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.textTertiary)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .background(Colors.backgroundCream)
            .navigationTitle("关于 HandsoMeng")
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
            
            VStack(spacing: 0) {
                content()
                    .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Colors.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - 联系方式行
    
    @ViewBuilder
    private func contactRow(
        icon: String,
        label: String,
        value: String,
        url: String
    ) -> some View {
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 13))
                        .foregroundColor(Colors.textSecondary)
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(Colors.textInk)
                }
                
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
    AboutDeveloperView()
}

