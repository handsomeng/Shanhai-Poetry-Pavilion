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
            
            VStack(spacing: Spacing.xxl) {
                Spacer()
                
                Text("山海诗馆")
                    .font(Fonts.titleLarge())
                    .foregroundColor(Colors.textInk)
                    .tracking(4)                   // 字间距
                
                Text("在这里开始你的诗歌之旅")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("笔名")
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textTertiary)
                        .tracking(1)
                    
                    TextField("", text: $penName, prompt: Text("给自己起个富有诗意的名字").foregroundColor(Colors.textTertiary))
                        .font(Fonts.bodyRegular())
                        .padding(.vertical, Spacing.md)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Colors.divider)
                            , alignment: .bottom
                        )
                }
                .padding(.horizontal, Spacing.xl)
                
                if showError {
                    Text(errorMessage)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.error)
                }
                
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
                        .font(Fonts.bodyLight())
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(Colors.accentTeal)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
        }
    }
}

