//
//  OnboardingView.swift
//  BetweenLines - 字里行间
//
//  Onboarding 引导页
//

import SwiftUI

/// Onboarding 容器，管理整个引导流程
struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Colors.backgroundCream.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // 第零页：开场欢迎
                WelcomeSplashView(onNext: {
                    withAnimation {
                        currentPage = 1
                    }
                })
                .tag(0)
                
                // 第一页：学习
                FeaturePageView(
                    icon: "book.fill",
                    title: "学习如何写现代诗",
                    description: "跟随 AI 导师的引导\n从零开始学习现代诗的创作技巧\n发现文字的韵律与美感",
                    pageIndex: 1,
                    totalPages: 5,
                    onNext: {
                        withAnimation {
                            currentPage = 2
                        }
                    }
                )
                .tag(1)
                
                // 第二页：练习
                FeaturePageView(
                    icon: "pencil.and.outline",
                    title: "练习如何写现代诗",
                    description: "通过主题写作和仿写练习\n在实践中提升你的创作能力\n每一次尝试都是进步",
                    pageIndex: 2,
                    totalPages: 5,
                    onNext: {
                        withAnimation {
                            currentPage = 3
                        }
                    }
                )
                .tag(2)
                
                // 第三页：分享
                FeaturePageView(
                    icon: "square.and.arrow.up.fill",
                    title: "分享你的创作",
                    description: "写完后可以分享到广场\n与其他诗友交流创作心得\n让你的文字被更多人看见",
                    pageIndex: 3,
                    totalPages: 5,
                    onNext: {
                        withAnimation {
                            currentPage = 4
                        }
                    }
                )
                .tag(3)
                
                // 第四页：笔名输入
                PenNamePageView(onComplete: onComplete, pageIndex: 4, totalPages: 5)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // 页面指示器（移到更低的位置）
            VStack {
                Spacer()
                
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Colors.accentTeal : Colors.border)
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 60) // 更低的位置，避免与按钮重合
                .opacity(currentPage == 0 ? 0 : 1) // 第 0 页隐藏指示器
                .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

/// 开场欢迎动画页
struct WelcomeSplashView: View {
    let onNext: () -> Void
    
    @State private var animateWelcome = false
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var autoAdvance = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: Spacing.xl) {
                // Logo
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Colors.textInk)
                    .opacity(animateWelcome ? 1 : 0)
                    .scaleEffect(animateWelcome ? 1 : 0.8)
                
                VStack(spacing: Spacing.md) {
                    // "欢迎来到"
                    Text("欢迎来到")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                        .tracking(3)
                        .opacity(animateWelcome ? 1 : 0)
                        .offset(y: animateWelcome ? 0 : 30)
                    
                    // "山海诗馆"
                    Text("山海诗馆")
                        .font(.system(size: 52, weight: .light, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .tracking(8)
                        .opacity(animateTitle ? 1 : 0)
                        .scaleEffect(animateTitle ? 1 : 0.8)
                    
                    // 副标题
                    Text("在这里开始你的诗歌之旅")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Colors.textTertiary)
                        .tracking(1.5)
                        .opacity(animateSubtitle ? 1 : 0)
                        .offset(y: animateSubtitle ? 0 : 20)
                }
            }
            
            Spacer()
            Spacer()
        }
        .contentShape(Rectangle()) // 让整个区域可点击
        .onTapGesture {
            // 点击任意位置跳过动画
            onNext()
        }
        .onAppear {
            // "欢迎来到" 淡入
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateWelcome = true
            }
            
            // "山海诗馆" 放大淡入
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.8)) {
                animateTitle = true
            }
            
            // 副标题 淡入
            withAnimation(.easeOut(duration: 0.8).delay(1.3)) {
                animateSubtitle = true
            }
            
            // 3 秒后自动跳转到下一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                if !autoAdvance {
                    autoAdvance = true
                    withAnimation {
                        onNext()
                    }
                }
            }
        }
    }
}

/// 功能介绍页 - 展示单个功能特点
struct FeaturePageView: View {
    let icon: String
    let title: String
    let description: String
    let pageIndex: Int
    let totalPages: Int
    let onNext: () -> Void
    
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 图标
            ZStack {
                Circle()
                    .fill(Colors.accentTeal.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1 : 0.5)
                    .opacity(animateIcon ? 1 : 0)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Colors.accentTeal)
                    .scaleEffect(animateIcon ? 1 : 0.5)
                    .opacity(animateIcon ? 1 : 0)
            }
            .padding(.bottom, Spacing.xxl)
            
            // 标题
            Text(title)
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundColor(Colors.textInk)
                .tracking(2)
                .multilineTextAlignment(.center)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : 20)
                .padding(.bottom, Spacing.lg)
            
            // 描述
            Text(description)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(Colors.textSecondary)
                .tracking(0.5)
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : 20)
                .padding(.horizontal, Spacing.xxl)
            
            Spacer()
            Spacer()
            
            // 下一步按钮
            Button(action: onNext) {
                HStack(spacing: Spacing.sm) {
                    Text(pageIndex == totalPages - 2 ? "开始创作" : "继续")
                        .font(.system(size: 15, weight: .regular))
                        .tracking(2)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .regular))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .foregroundColor(.white)
                .background(Colors.accentTeal)
            }
            .scaleButtonStyle()
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 100) // 留出空间给页面指示器
            .opacity(animateText ? 1 : 0)
            .offset(y: animateText ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                animateText = true
            }
        }
    }
}

/// 笔名输入页
struct PenNamePageView: View {
    let onComplete: () -> Void
    let pageIndex: Int
    let totalPages: Int
    
    @StateObject private var identityService = UserIdentityService()
    @State private var penName: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // 标题
            VStack(spacing: Spacing.sm) {
                Text("给自己起个名字")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .tracking(2)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                Text("这是你在山海诗馆的诗人身份")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Colors.textTertiary)
                    .tracking(1)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
            }
            .padding(.bottom, Spacing.md)
            
            // 输入框
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("笔名")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(Colors.textSecondary)
                    .tracking(2)
                    .textCase(.uppercase)
                
                TextField("", text: $penName, prompt: Text("例如：云中漫步者").foregroundColor(Colors.textQuaternary))
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
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
            
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
                // 保存笔名到 UserIdentityService
                identityService.setPenName(trimmed)
                // 同时保存到 UserDefaults（兼容旧代码）
                UserDefaults.standard.set(trimmed, forKey: "penName")
                // 完成引导
                completeOnboarding()
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
            .padding(.bottom, 100) // 留出空间给页面指示器
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}

