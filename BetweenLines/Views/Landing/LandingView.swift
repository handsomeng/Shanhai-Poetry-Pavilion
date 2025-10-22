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
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // 主标题 - 优化字重和间距
                Text("山海诗馆")
                    .font(.system(size: 40, weight: .light, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .tracking(4)
                    .padding(.bottom, Spacing.xs)
                
                // 副标题
                Text("在这里开始你的诗歌之旅")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Colors.textTertiary)
                    .tracking(1)
                
                // 输入框
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("笔名")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                        .tracking(2)
                        .textCase(.uppercase)
                    
                    TextField("", text: $penName, prompt: Text("给自己起个富有诗意的名字").foregroundColor(Colors.textQuaternary))
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .padding(.vertical, Spacing.md)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Colors.border)
                            , alignment: .bottom
                        )
                }
                .padding(.horizontal, Spacing.xl)
                
                if showError {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Colors.error)
                }
                
                // 按钮
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
                        .font(.system(size: 15, weight: .regular))
                        .tracking(2)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .foregroundColor(.white)
                        .background(Colors.accentTeal)
                }
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
                Spacer()
            }
        }
    }
}

