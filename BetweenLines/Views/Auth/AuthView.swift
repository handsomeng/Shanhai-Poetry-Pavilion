//
//  AuthView.swift
//  山海诗馆
//
//  登录/注册视图
//

import SwiftUI

struct AuthView: View {
    
    @StateObject private var authService = AuthService.shared
    @StateObject private var toastManager = ToastManager.shared
    
    @State private var isLoginMode = true  // true=登录, false=注册
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 顶部标题
                        headerSection
                        
                        // 登录/注册表单
                        formSection
                        
                        // 提交按钮
                        submitButton
                        
                        // 切换模式
                        switchModeButton
                        
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xxxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            // Logo 或图标
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60, weight: .thin))
                .foregroundColor(Colors.accentTeal)
            
            Text(isLoginMode ? "欢迎回来" : "加入山海诗馆")
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text(isLoginMode ? "继续你的诗歌之旅" : "开始创作属于你的诗篇")
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            // 用户名（仅注册）
            if !isLoginMode {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("用户名")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                    
                    TextField("请输入用户名（2-20字符）", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.username)
                        .autocapitalization(.none)
                }
            }
            
            // 邮箱
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("邮箱")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                
                TextField("请输入邮箱", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            // 密码
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("密码")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                
                SecureField("请输入密码（至少6位）", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(isLoginMode ? .password : .newPassword)
            }
            
            // 确认密码（仅注册）
            if !isLoginMode {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("确认密码")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                    
                    SecureField("请再次输入密码", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                }
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: handleSubmit) {
            HStack {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(isLoginMode ? "登录" : "注册")
                        .font(Fonts.bodyRegular())
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Colors.accentTeal)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.medium)
        }
        .disabled(authService.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
    }
    
    // MARK: - Switch Mode Button
    
    private var switchModeButton: some View {
        Button(action: {
            withAnimation {
                isLoginMode.toggle()
                clearForm()
            }
        }) {
            HStack(spacing: 4) {
                Text(isLoginMode ? "还没有账号？" : "已有账号？")
                    .foregroundColor(Colors.textSecondary)
                Text(isLoginMode ? "立即注册" : "立即登录")
                    .foregroundColor(Colors.accentTeal)
                    .fontWeight(.medium)
            }
            .font(Fonts.bodyRegular())
        }
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        Task {
            do {
                if isLoginMode {
                    // 登录
                    try await authService.signInWithEmail(
                        email: email.trimmingCharacters(in: .whitespaces),
                        password: password
                    )
                    toastManager.showSuccess("登录成功！")
                    dismiss()
                } else {
                    // 注册
                    guard password == confirmPassword else {
                        toastManager.showError("两次密码输入不一致")
                        return
                    }
                    
                    try await authService.signUpWithEmail(
                        email: email.trimmingCharacters(in: .whitespaces),
                        password: password,
                        username: username.trimmingCharacters(in: .whitespaces)
                    )
                    toastManager.showSuccess("注册成功！")
                    dismiss()
                }
            } catch {
                toastManager.showError(error.localizedDescription)
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        username = ""
        confirmPassword = ""
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        let emailValid = !email.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordValid = password.count >= 6
        
        if isLoginMode {
            return emailValid && passwordValid
        } else {
            let usernameValid = username.trimmingCharacters(in: .whitespaces).count >= 2
            let passwordsMatch = password == confirmPassword
            return emailValid && passwordValid && usernameValid && passwordsMatch
        }
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(Spacing.md)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Colors.textQuaternary, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview("登录模式") {
    AuthView()
}

