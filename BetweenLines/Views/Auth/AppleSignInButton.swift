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
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        onRequest(request)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AppleSignInCoordinator(onCompletion: onCompletion)
        controller.performRequests()
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
        onCompletion(.success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion(.failure(error))
    }
}

