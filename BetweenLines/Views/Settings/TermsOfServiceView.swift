//
//  TermsOfServiceView.swift
//  BetweenLines - 字里行间
//
//  用户协议
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // 标题
                Text("用户协议")
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
                        title: "1. 服务条款接受",
                        content: """
                        欢迎使用山海诗馆。使用本应用即表示您同意遵守本用户协议。如果您不同意本协议的任何条款，请不要使用本应用。
                        """
                    )
                    
                    sectionView(
                        title: "2. 服务说明",
                        content: """
                        山海诗馆是一款诗歌创作与管理工具，提供以下功能：
                        
                        • 诗歌创作：直接写作、主题写作、仿写练习
                        • 数据管理：本地存储、iCloud 同步
                        • AI 辅助：主题生成、仿写示例
                        • 分享功能：生成诗歌图片、保存到相册
                        
                        我们致力于为您提供优质的创作体验。
                        """
                    )
                    
                    sectionView(
                        title: "3. 用户责任",
                        content: """
                        使用本应用时，您需要：
                        
                        • 确保您创作的内容不侵犯他人权益
                        • 不发布违法、暴力、色情等不当内容
                        • 不利用本应用进行任何违法活动
                        • 妥善保管您的账号信息
                        
                        您对自己的创作内容负全部责任。
                        """
                    )
                    
                    sectionView(
                        title: "4. 知识产权",
                        content: """
                        • 您创作的诗歌内容版权归您所有
                        • 山海诗馆的界面设计、代码等知识产权归开发者所有
                        • 您授予我们非独占的、免费的使用许可，以提供和改进服务
                        """
                    )
                    
                    sectionView(
                        title: "5. 服务变更",
                        content: """
                        我们保留随时修改或中断服务的权利，包括但不限于：
                        
                        • 添加或删除功能
                        • 调整服务政策
                        • 维护和升级
                        
                        我们会尽力提前通知重大变更。
                        """
                    )
                    
                    sectionView(
                        title: "6. 免责声明",
                        content: """
                        • 本应用按"现状"提供，不保证绝对无错误
                        • 我们不对因使用本应用造成的任何损失负责
                        • AI 生成的内容仅供参考，不代表我们的观点
                        • 您应自行备份重要数据
                        """
                    )
                    
                    sectionView(
                        title: "7. 订阅服务条款",
                        content: """
                        自动续期订阅说明：
                        
                        • 订阅周期：月度、季度或年度订阅
                        • 免费试用：所有订阅提供 7 天免费试用期
                        • 自动续费：订阅将自动续期，除非在当前周期结束前至少 24 小时取消
                        • 取消方式：在 iPhone 的"设置" → "Apple ID" → "订阅"中管理
                        • 退款政策：试用期内取消不收费，已付费用户可联系 Apple 申请退款
                        
                        订阅价格：
                        • 月度订阅：¥9.9/月
                        • 季度订阅：¥19.9/季（推荐）
                        • 年度订阅：¥69.9/年
                        
                        付款将在确认购买时从您的 Apple ID 账户扣除。
                        """
                    )
                    
                    sectionView(
                        title: "8. 账号终止",
                        content: """
                        您可以随时删除账号。删除后：
                        
                        • 您的账号信息将被永久删除
                        • 本地和云端的诗歌数据将被清空
                        • 此操作不可恢复
                        
                        我们也保留在必要时终止违规账号的权利。
                        """
                    )
                    
                    sectionView(
                        title: "9. 争议解决",
                        content: """
                        本协议受中华人民共和国法律管辖。如发生争议，双方应友好协商解决。
                        """
                    )
                    
                    sectionView(
                        title: "10. 联系方式",
                        content: """
                        如有任何问题，请联系我们：
                        
                        邮箱：martinwm2011@hotmail.com
                        """
                    )
                }
            }
            .padding(Spacing.lg)
        }
        .background(Colors.backgroundCream)
        .navigationTitle("用户协议")
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
        TermsOfServiceView()
    }
}

