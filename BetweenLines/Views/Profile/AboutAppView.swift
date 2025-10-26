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
            VStack(spacing: 32) {
                // App Logo/Icon
                VStack(spacing: 16) {
                    // App图标
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
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
                
                // 主要内容 - 纯文字信件格式
                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    你好呀，欢迎来到山海诗馆。
                    
                    这是一款专为现代诗爱好者打造的写诗应用。
                    
                    作为一个普普通通的现代诗爱好者，从一点都不会写，到在 AI 的陪伴下慢慢写出 10 首，20首，100 首 …… 现代诗成为了我必不可少的生命力量之一。
                    
                    我也相信，诗歌不应该是高不可攀的艺术，每个人心中都有属于自己的山海。
                    
                    在这里，你可以自由创作，记录灵感，学习技巧，让诗歌成为生活的一部分。
                    
                    
                    核心功能
                    
                    多种写诗模式：主题写诗、仿写练习、自由创作，让创作更有趣。
                    
                    系统学习：从零开始，系统学习现代诗创作，包括意象的构建与运用、节奏与韵律的把握、情感的表达与升华、诗歌美学的理解。
                    
                    精美模板：一键生成分享图片，多种精美模板可选，实时预览切换，优雅的排版设计，适合社交媒体分享。
                    
                    iCloud同步：所有设备无缝同步，数据安全可靠，无需登录账号，隐私完全保护。
                    
                    诗人等级体系：从"初见诗人"到"谪仙诗人"，记录你的创作历程。
                    
                    设计理念
                    
                    简洁优雅：界面设计遵循现代审美，去除一切繁杂，只留下诗歌与你。
                    
                    专注创作：没有社交压力，没有点赞焦虑，只有纯粹的创作体验。
                    
                    尊重创作者：你的诗歌属于你自己，我们保护你的隐私和创作权益。
                    
                    
                    会员权益
                    
                    升级会员后，你将解锁更多创作可能：无限次AI点评（免费用户每日3次）、所有精美模板、优先体验新功能、支持独立开发者。
                    
                    山海在眼前，免费试用7天。
                    
                    
                    联系我
                    
                    如有任何问题或建议，欢迎与我联系：martinwm2011@hotmail.com
                    
                    
                    致谢
                    
                    感谢所有使用山海诗馆的诗人们，是你们让这个应用充满生命力。
                    
                    感谢 Cursor、Claude、DeepSeek 在开发过程中的帮助。
                    """)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 版权信息
                VStack(spacing: 8) {
                    Text("© 2025 山海诗馆. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.textTertiary)
                    
                    Text("Between Lines - 在字里行间，发现诗意人生")
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(Colors.textTertiary.opacity(0.8))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .background(Colors.backgroundCream)
        .navigationTitle("关于山海诗馆")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AboutAppView()
    }
}

