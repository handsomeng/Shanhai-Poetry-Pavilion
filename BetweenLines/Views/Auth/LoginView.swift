//
//  LoginView.swift
//  山海诗馆
//
//  登录/注册界面
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var authService = AuthService.shared
    @StateObject private var toastManager = ToastManager.shared
    
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isLoading = false
    
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
                        
                        // 表单
                        formSection
                        
                        // 提交按钮
                        submitButton
                        
                        // 切换按钮
                        switchModeButton
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
            
            Text(isSignUp ? "加入诗馆" : "欢迎回来")
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text(isSignUp ? "创建账号，开始创作之旅" : "登录以发布和管理你的诗歌")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.xl)
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
                        .font(Fonts.buttonLarge())
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
                        toastManager.show("注册成功！欢迎加入诗馆", type: .success)
                        dismiss()
                    }
                } else {
                    try await authService.signIn(email: email, password: password)
                    await MainActor.run {
                        toastManager.show("登录成功！", type: .success)
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    toastManager.show(error.localizedDescription, type: .error)
                    isLoading = false
                }
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

