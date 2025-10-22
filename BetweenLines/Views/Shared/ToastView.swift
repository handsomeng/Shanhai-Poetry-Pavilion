//
//  ToastView.swift
//  山海诗馆
//
//  Toast 通知组件：轻量级提示反馈
//

import SwiftUI

// MARK: - Toast Model
struct Toast: Equatable {
    enum ToastType {
        case success
        case error
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return Colors.accentTeal
            case .error: return Colors.error
            case .info: return Colors.textSecondary
            }
        }
    }
    
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: Double
    
    init(message: String, type: ToastType = .info, duration: Double = 2.0) {
        self.message = message
        self.type = type
        self.duration = duration
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toast: Toast?
    
    private init() {}
    
    func show(message: String, type: Toast.ToastType = .info, duration: Double = 2.0) {
        // 显示新 Toast
        withAnimation(.easeInOut(duration: 0.3)) {
            toast = Toast(message: message, type: type, duration: duration)
        }
        
        // 自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.toast = nil
            }
        }
    }
    
    func showSuccess(_ message: String) {
        show(message: message, type: .success)
    }
    
    func showError(_ message: String) {
        show(message: message, type: .error, duration: 3.0)
    }
    
    func showInfo(_ message: String) {
        show(message: message, type: .info)
    }
    
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            toast = nil
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(toast.type.color)
            
            Text(toast.message)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
                .lineLimit(2)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Colors.white)
                .shadow(color: Colors.textInk.opacity(0.12), radius: 16, x: 0, y: 4)
        )
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Toast 容器
            if let toast = toastManager.toast {
                VStack {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: toastManager.toast != nil)
                        .onTapGesture {
                            toastManager.dismiss()
                        }
                    
                    Spacer()
                }
                .padding(.top, 60) // 距离顶部安全区域的距离
                .zIndex(999)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func withToast() -> some View {
        self.modifier(ToastModifier())
    }
}

