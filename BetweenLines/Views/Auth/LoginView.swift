//
//  LoginView.swift
//  山海诗馆
//
//  登录/注册界面
//

import SwiftUI
import AuthenticationServices

// MARK: - Timeout Helper

struct TimeoutError: Error {}

func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // 添加实际操作
        group.addTask {
            try await operation()
        }
        
        // 添加超时任务
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        
        // 返回第一个完成的任务结果
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// MARK: - Login View

struct LoginView: View {
    
    @StateObject private var authService = AuthService.shared
    @StateObject private var errorHandler = ErrorHandler.shared
    
    @State private var isLoading = false
    @State private var isPreparingNetwork = true
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
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
                        
                        if isPreparingNetwork {
                            // 网络准备中
                            VStack(spacing: Spacing.md) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Colors.accentTeal))
                                
                                Text("正在准备网络连接...")
                                    .font(Fonts.caption())
                                    .foregroundColor(Colors.textSecondary)
                            }
                            .frame(height: 100)
                        } else {
                            // Apple 登录
                            appleSignInSection
                            
                            // 提示文字
                            Text("使用 Apple ID 快速登录，安全且保护隐私")
                                .font(Fonts.caption())
                                .foregroundColor(Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                            
                            // 协议链接
                            agreementSection
                        }
                        
                        Spacer()
                            .frame(height: Spacing.xl)
                    }
                    .padding(Spacing.xl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 界面加载时预先触发网络权限
            print("🌐 [LoginView] 开始网络预检...")
            _ = await SupabaseHTTPClient.ensureNetworkPermission()
            await MainActor.run {
                isPreparingNetwork = false
                print("🌐 [LoginView] 网络预检完成")
            }
        }
        .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textInk)
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                NavigationStack {
                    PrivacyPolicyView()
                }
            }
            .sheet(isPresented: $showTermsOfService) {
                NavigationStack {
                    TermsOfServiceView()
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
        print("🍎 [DEBUG] ===== Apple Sign In 回调触发 =====")
        
        switch result {
        case .success(let authorization):
            print("✅ [DEBUG] ASAuthorization 成功")
            
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("❌ [DEBUG] 无法转换为 ASAuthorizationAppleIDCredential")
                errorHandler.handle(SupabaseError.unknown("无法获取 Apple 登录凭证"))
                return
            }
            
            print("✅ [DEBUG] 获取到 credential")
            print("🆔 [DEBUG] user: \(credential.user)")
            print("📧 [DEBUG] email: \(String(describing: credential.email))")
            print("👤 [DEBUG] fullName: \(String(describing: credential.fullName))")
            print("🔑 [DEBUG] identityToken: \(credential.identityToken != nil ? "存在" : "不存在")")
            
            isLoading = true
            
            Task {
                do {
                    print("🍎 [DEBUG] 开始调用 authService.signInWithApple...")
                    
                    // 添加超时机制（15秒）
                    try await withTimeout(seconds: 15) {
                        try await authService.signInWithApple(credential: credential)
                    }
                    
                    print("✅ [DEBUG] Apple 登录成功！用户：\(authService.currentProfile?.username ?? "未知")")
                    
                    // 延迟一点点，让用户看到"登录中"的反馈
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                    
                    await MainActor.run {
                        isLoading = false
                        print("🚪 准备关闭登录界面...")
                        dismiss()
                    }
                } catch is TimeoutError {
                    print("❌ 登录超时")
                    await MainActor.run {
                        errorHandler.handle(SupabaseError.unknown("登录超时，请检查网络连接后重试"))
                        isLoading = false
                    }
                } catch {
                    print("❌ Apple 登录失败：\(error.localizedDescription)")
                    await MainActor.run {
                        // 如果是网络错误，给出更友好的提示
                        if error.localizedDescription.contains("network") || 
                           error.localizedDescription.contains("Internet") ||
                           error.localizedDescription.contains("connection") {
                            errorHandler.handle(SupabaseError.unknown("网络连接失败，请检查网络后重试"))
                        } else {
                            errorHandler.handle(error)
                        }
                        isLoading = false
                    }
                }
            }
            
        case .failure(let error):
            print("❌ [DEBUG] ===== Apple Sign In 失败 =====")
            let nsError = error as NSError
            print("❌ [DEBUG] Error domain: \(nsError.domain)")
            print("❌ [DEBUG] Error code: \(nsError.code)")
            print("❌ [DEBUG] Error description: \(error.localizedDescription)")
            print("❌ [DEBUG] Error userInfo: \(nsError.userInfo)")
            
            // 用户取消登录不显示错误
            if nsError.code != 1001 {
                print("❌ [DEBUG] 显示错误给用户")
                errorHandler.handle(error)
            } else {
                print("ℹ️ [DEBUG] 用户取消了登录（Code 1001），不显示错误")
            }
        }
    }
    
    // MARK: - Agreement Section
    
    private var agreementSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("登录即表示同意")
                .font(.system(size: 11, weight: .light))
                .foregroundColor(Colors.textTertiary)
            
            HStack(spacing: 4) {
                Button(action: {
                    showTermsOfService = true
                }) {
                    Text("《用户协议》")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Colors.accentTeal)
                        .underline()
                }
                
                Text("和")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(Colors.textTertiary)
                
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    Text("《隐私政策》")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Colors.accentTeal)
                        .underline()
                }
            }
        }
        .padding(.top, Spacing.md)
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

