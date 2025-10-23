//
//  AppleSignInButton.swift
//  山海诗馆
//
//  自定义中文 Apple 登录按钮
//

import SwiftUI
import AuthenticationServices

struct CustomAppleSignInButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    var body: some View {
        Button {
            performAppleSignIn()
        } label: {
            HStack(spacing: 12) {
                // Apple Logo
                Image(systemName: "apple.logo")
                    .font(.system(size: 20, weight: .medium))
                
                Text("使用 Apple 登录")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(CornerRadius.medium)
        }
        .buttonStyle(AppleSignInButtonStyle())
    }
    
    private func performAppleSignIn() {
        print("🍎 [DEBUG] ===== 准备开始 Apple Sign In =====")
        
        let provider = ASAuthorizationAppleIDProvider()
        print("✅ [DEBUG] 创建 ASAuthorizationAppleIDProvider")
        
        let request = provider.createRequest()
        print("✅ [DEBUG] 创建 request")
        
        onRequest(request)
        print("✅ [DEBUG] requestedScopes: \(String(describing: request.requestedScopes))")
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AppleSignInCoordinator(onCompletion: onCompletion)
        print("✅ [DEBUG] 创建 ASAuthorizationController")
        
        print("🚀 [DEBUG] 调用 performRequests()...")
        controller.performRequests()
        print("✅ [DEBUG] performRequests() 已调用")
    }
}

// MARK: - Button Style

struct AppleSignInButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Coordinator

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    let onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    init(onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onCompletion = onCompletion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("✅ [DEBUG] Coordinator: 收到授权成功回调")
        onCompletion(.success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ [DEBUG] Coordinator: 收到授权失败回调")
        let nsError = error as NSError
        print("❌ [DEBUG] Coordinator: Error domain: \(nsError.domain)")
        print("❌ [DEBUG] Coordinator: Error code: \(nsError.code)")
        onCompletion(.failure(error))
    }
}

