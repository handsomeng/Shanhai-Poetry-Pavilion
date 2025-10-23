//
//  LoginView.swift
//  山海诗馆
//
//  登录/注册界面
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @StateObject private var authService = AuthService.shared
    @StateObject private var errorHandler = ErrorHandler.shared
    
    @State private var isLoading = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                // Loading 遮罩
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("登录中...")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(.white)
                    }
                    .padding(Spacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color.black.opacity(0.7))
                    )
                }
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Logo 和标题
                        header
                        
                        // Apple 登录
                        appleSignInSection
                        
                        // 提示文字
                        Text("使用 Apple ID 快速登录，安全且保护隐私")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                    .padding(Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textInk)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: Spacing.md) {
            Text("🏮")
                .font(.system(size: 80))
            
            Text("欢迎来到山海诗馆")
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text("登录以发布和管理你的诗歌")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.xl)
    }
    
    // MARK: - Apple Sign In Section
    
    private var appleSignInSection: some View {
        CustomAppleSignInButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                handleAppleSignIn(result)
            }
        )
    }
    
    
    // MARK: - Handle Apple Sign In
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorHandler.handle(SupabaseError.unknown("无法获取 Apple 登录凭证"))
                return
            }
            
            isLoading = true
            
            Task {
                do {
                    print("🍎 开始 Apple 登录...")
                    try await authService.signInWithApple(credential: credential)
                    print("✅ Apple 登录成功！用户：\(authService.currentProfile?.username ?? "未知")")
                    
                    // 延迟一点点，让用户看到"登录中"的反馈
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                    
                    await MainActor.run {
                        isLoading = false
                        print("🚪 准备关闭登录界面...")
                        dismiss()
                    }
                } catch {
                    print("❌ Apple 登录失败：\(error.localizedDescription)")
                    await MainActor.run {
                        errorHandler.handle(error)
                        isLoading = false
                    }
                }
            }
            
        case .failure(let error):
            // 用户取消登录不显示错误
            if (error as NSError).code != 1001 {
                print("❌ Apple 授权失败：\(error.localizedDescription)")
                errorHandler.handle(error)
            } else {
                print("ℹ️ 用户取消了 Apple 登录")
            }
        }
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(Colors.textSecondary.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}

