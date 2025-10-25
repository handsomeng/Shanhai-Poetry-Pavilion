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
    @State private var showLoginInvitation = false
    @State private var showLoginSheet = false
    
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
                    // 保存笔名
                    UserDefaults.standard.set(trimmed, forKey: "penName")
                    // 显示登录邀请
                    showLoginInvitation = true
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
                .scaleButtonStyle()
                .padding(.horizontal, Spacing.xl)
                
                Spacer()
                Spacer()
            }
        }
        .alert("登录云端账号", isPresented: $showLoginInvitation) {
            Button("立即登录", role: nil) {
                // 先触发网络权限请求，再显示登录界面
                Task {
                    print("🌐 [Onboarding] 开始网络预检...")
                    _ = await SupabaseHTTPClient.ensureNetworkPermission()
                    
                    // 给一个小延迟，确保权限弹窗处理完毕
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                    
                    await MainActor.run {
                        print("🌐 [Onboarding] 网络预检完成，显示登录界面")
                        showLoginSheet = true
                    }
                }
            }
            Button("稍后再说", role: .cancel) {
                completeOnboarding()
            }
        } message: {
            Text("登录后可以将作品发布到广场，与其他诗友交流，还能云端保存你的创作")
        }
        .onChange(of: showLoginSheet) { oldValue, newValue in
            // 当登录界面关闭时，完成 onboarding
            if oldValue == true && newValue == false {
                completeOnboarding()
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        onComplete()
    }
}

