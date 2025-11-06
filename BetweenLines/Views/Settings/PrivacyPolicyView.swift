//
//  PrivacyPolicyView.swift
//  BetweenLines - 字里行间
//
//  隐私政策
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // 标题
                Text("隐私政策")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .padding(.bottom, Spacing.sm)
                
                Text("最后更新日期：2025年10月")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Colors.textSecondary)
                    .padding(.bottom, Spacing.xl)
                
                // 内容
                Group {
                    sectionView(
                        title: "1. 信息收集",
                        content: """
                        我们重视您的隐私。山海诗馆收集和使用以下信息：
                        
                        • Apple ID 信息：用于账号登录和身份验证
                        • 诗歌内容：您创作的诗歌文本
                        • 使用数据：诗歌数量、创作时间等统计信息
                        
                        所有数据仅用于提供服务，不会用于其他用途。
                        """
                    )
                    
                    sectionView(
                        title: "2. 数据存储",
                        content: """
                        • 本地存储：您的诗歌存储在设备本地
                        • iCloud 同步：登录后，数据自动同步到您的 iCloud（需开启 iCloud）
                        • 后端存储：仅存储必要的账号信息和统计数据
                        
                        我们采用行业标准的加密措施保护您的数据。
                        """
                    )
                    
                    sectionView(
                        title: "3. 数据使用",
                        content: """
                        我们收集的数据仅用于：
                        
                        • 提供诗歌创作和管理功能
                        • 改进应用体验
                        • 提供技术支持
                        
                        我们不会将您的个人信息出售、出租或分享给第三方。
                        """
                    )
                    
                    sectionView(
                        title: "4. AI 服务",
                        content: """
                        山海诗馆使用第三方 AI 服务（DeepSeek）提供写作辅助功能：
                        
                        • 您的写作请求会发送到 AI 服务进行处理
                        • 我们不会存储或分享您与 AI 的对话内容
                        • AI 服务提供商有其独立的隐私政策
                        """
                    )
                    
                    sectionView(
                        title: "5. 用户权利",
                        content: """
                        您拥有以下权利：
                        
                        • 随时查看、编辑或删除您的诗歌
                        • 导出您的所有数据
                        • 删除您的账号和所有关联数据
                        • 选择是否使用 iCloud 同步
                        """
                    )
                    
                    sectionView(
                        title: "6. 儿童隐私",
                        content: """
                        山海诗馆适合所有年龄段用户使用。我们不会主动收集 13 岁以下儿童的个人信息。
                        """
                    )
                    
                    sectionView(
                        title: "7. 订阅与支付",
                        content: """
                        山海诗馆提供自动续期订阅服务：
                        
                        • 订阅信息通过 Apple 的 StoreKit 处理
                        • 我们不会存储您的支付信息
                        • 订阅管理由 App Store 统一处理
                        • 您可以随时在 App Store 设置中取消订阅
                        """
                    )
                    
                    sectionView(
                        title: "8. 政策更新",
                        content: """
                        我们可能会不定期更新本隐私政策。重大变更时，我们会在应用内通知您。
                        """
                    )
                    
                    sectionView(
                        title: "9. 联系我们",
                        content: """
                        如有任何关于隐私的问题，请联系我们：
                        
                        邮箱：martinwm2011@hotmail.com
                        """
                    )
                }
            }
            .padding(Spacing.lg)
        }
        .background(Colors.backgroundCream)
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Section View
    
    private func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Colors.textInk)
            
            Text(content)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.bottom, Spacing.md)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

