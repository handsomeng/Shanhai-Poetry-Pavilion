//
//  LandingView.swift
//  BetweenLines - 字里行间
//
//  首启引导页
//

import SwiftUI

struct LandingView: View {
    let onComplete: () -> Void
    @State private var penName: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {
            Colors.backgroundCream.ignoresSafeArea()
            
            VStack(spacing: Spacing.huge) {
                Spacer()
                
                // 主标题 - Dribbble 风格：超大、超细
                Text("山海诗馆")
                    .font(Fonts.displayLarge())
                    .foregroundColor(Colors.textInk)
                    .tracking(8)                   // 增大字间距
                    .padding(.bottom, Spacing.xs)
                
                // 副标题 - 极致轻盈
                Text("在这里开始你的诗歌之旅")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textTertiary)
                    .tracking(2)
                
                // 输入框 - 极简无边框设计
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("笔名")
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textQuaternary)
                        .tracking(3)
                        .textCase(.uppercase)     // 小写变大写，更高级
                    
                    TextField("", text: $penName, prompt: Text("给自己起个富有诗意的名字").foregroundColor(Colors.textQuaternary))
                        .font(Fonts.titleSmall())
                        .foregroundColor(Colors.textInk)
                        .padding(.vertical, Spacing.lg)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.3)      // 更细的线
                                .foregroundColor(Colors.border)
                            , alignment: .bottom
                        )
                }
                .padding(.horizontal, Spacing.xxl)   // 更大的边距
                
                if showError {
                    Text(errorMessage)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.error)
                }
                
                // 按钮 - 极简边框风格
                Button(action: {
                    let trimmed = penName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count < ContentLimits.penNameMin {
                        errorMessage = "笔名至少需要 \(ContentLimits.penNameMin) 个字符"
                        showError = true
                        return
                    }
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
                    UserDefaults.standard.set(trimmed, forKey: "penName")
                    onComplete()
                }) {
                    Text("开始创作")
                        .font(Fonts.bodyRegular())
                        .tracking(4)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xl)
                        .foregroundColor(.white)
                        .background(Colors.accentTeal)
                        .overlay(
                            Rectangle()
                                .stroke(Colors.accentTeal, lineWidth: 0.5)
                        )
                }
                .padding(.horizontal, Spacing.xxl)
                
                Spacer()
            }
        }
    }
}

