//
//  AboutView.swift
//  BetweenLines - 字里行间
//
//  关于页面
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 从 Bundle 获取版本信息
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                // Logo 和标题
                VStack(spacing: Spacing.lg) {
                    // App Logo
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Colors.textInk)
                    
                    Text("山海诗馆")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .tracking(4)
                    
                    Text("在这里开始你的诗歌之旅")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                        .tracking(1)
                }
                .padding(.top, Spacing.xl)
                
                // 版本信息
                VStack(spacing: Spacing.xs) {
                    Text("版本 \(appVersion)")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                    
                    Text("Build \(buildNumber)")
                        .font(.system(size: 11, weight: .ultraLight))
                        .foregroundColor(Colors.textTertiary)
                }
                
                Divider()
                    .padding(.horizontal, Spacing.xxl)
                
                // 功能介绍
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    featureRow(icon: "book.fill", text: "学习如何写现代诗")
                    featureRow(icon: "pencil.and.outline", text: "练习如何写现代诗")
                    featureRow(icon: "square.and.arrow.up.fill", text: "分享你的创作")
                    featureRow(icon: "icloud.fill", text: "iCloud 云端同步")
                }
                .padding(.horizontal, Spacing.xl)
                
                Divider()
                    .padding(.horizontal, Spacing.xxl)
                
                // 开发团队
                VStack(spacing: Spacing.sm) {
                    Text("开发团队")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.textInk)
                    
                    Text("山海诗馆团队")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                }
                
                // 联系方式
                VStack(spacing: Spacing.sm) {
                    Text("联系我们")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.textInk)
                    
                    Button(action: {
                        if let url = URL(string: "mailto:support@shanhaishiguan.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("support@shanhaishiguan.com")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(Colors.accentTeal)
                    }
                }
                
                // 致谢
                VStack(spacing: Spacing.sm) {
                    Text("特别感谢")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.textInk)
                    
                    VStack(spacing: Spacing.xs) {
                        Text("DeepSeek AI")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Colors.textSecondary)
                        
                        Text("所有使用山海诗馆的诗人们")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                
                // 版权信息
                Text("© 2024 山海诗馆. All rights reserved.")
                    .font(.system(size: 11, weight: .ultraLight))
                    .foregroundColor(Colors.textTertiary)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
            }
        }
        .background(Colors.backgroundCream)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Feature Row
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Colors.accentTeal)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Colors.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

