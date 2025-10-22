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
    
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isLoading = false
    @State private var showEmailLogin = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Logo 和标题
                        header
                        
                        // Apple 登录（主推荐）
                        if !showEmailLogin {
                            appleSignInSection
                            
                            // 分割线
                            dividerSection
                            
                            // 邮箱登录入口
                            emailLoginEntryButton
                        } else {
                            // 表单
                            formSection
                            
                            // 提交按钮
                            submitButton
                            
                            // 切换按钮
                            switchModeButton
                            
                            // 返回按钮
                            backToAppleButton
                        }
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
        VStack(spacing: Spacing.md) {
            CustomAppleSignInButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    handleAppleSignIn(result)
                }
            )
            
            Text("推荐使用 Apple 登录，快速且安全")
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Divider
    
    private var dividerSection: some View {
        HStack(spacing: Spacing.md) {
            Rectangle()
                .fill(Colors.textSecondary.opacity(0.3))
                .frame(height: 1)
            
            Text("或")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
            
            Rectangle()
                .fill(Colors.textSecondary.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.vertical, Spacing.sm)
    }
    
    // MARK: - Email Login Entry
    
    private var emailLoginEntryButton: some View {
        Button {
            withAnimation {
                showEmailLogin = true
            }
        } label: {
            HStack {
                Image(systemName: "envelope")
                Text("使用邮箱登录")
                    .font(Fonts.bodyRegular())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(Colors.textInk)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Colors.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Back to Apple Button
    
    private var backToAppleButton: some View {
        Button {
            withAnimation {
                showEmailLogin = false
                clearForm()
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "chevron.left")
                Text("返回")
            }
            .font(Fonts.bodyRegular())
            .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Form
    
    private var formSection: some View {
        VStack(spacing: Spacing.lg) {
            // 用户名（仅注册时）
            if isSignUp {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("用户名")
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textInk)
                    
                    TextField("请输入用户名", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.none)
                }
            }
            
            // 邮箱
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("邮箱")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                
                TextField("请输入邮箱", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            // 密码
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("密码")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                
                SecureField("请输入密码（至少6位）", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            handleSubmit()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(isSignUp ? "注册" : "登录")
                        .font(Fonts.bodyLarge())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Colors.accentTeal)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.medium)
        }
        .disabled(isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
    }
    
    // MARK: - Switch Mode Button
    
    private var switchModeButton: some View {
        Button {
            withAnimation {
                isSignUp.toggle()
                clearForm()
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Text(isSignUp ? "已有账号？" : "还没有账号？")
                    .foregroundColor(Colors.textSecondary)
                Text(isSignUp ? "去登录" : "去注册")
                    .foregroundColor(Colors.accentTeal)
            }
            .font(Fonts.bodyRegular())
        }
    }
    
    // MARK: - Helper
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        username = ""
    }
    
    private func handleSubmit() {
        guard isFormValid else { return }
        
        isLoading = true
        
        Task {
            do {
                if isSignUp {
                    try await authService.signUp(email: email, password: password, username: username)
                    await MainActor.run {
                        // 注册成功，直接关闭
                        dismiss()
                    }
                } else {
                    try await authService.signIn(email: email, password: password)
                    await MainActor.run {
                        // 登录成功，直接关闭
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
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
                    try await authService.signInWithApple(credential: credential)
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    await MainActor.run {
                        errorHandler.handle(error)
                        isLoading = false
                    }
                }
            }
            
        case .failure(let error):
            // 用户取消登录不显示错误
            if (error as NSError).code != 1001 {
                errorHandler.handle(error)
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

