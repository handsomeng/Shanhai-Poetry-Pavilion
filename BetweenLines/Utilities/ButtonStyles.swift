//
//  ButtonStyles.swift
//  山海诗馆
//
//  自定义按钮样式：提供统一的触控反馈和交互体验
//

import SwiftUI

// MARK: - Scale Button Style
/// 点击时缩放的按钮样式，提供触觉反馈
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Primary Button Style
/// 主要按钮样式：黑色背景 + 缩放反馈
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Fonts.bodyRegular())
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(isDisabled ? Colors.textQuaternary : Colors.accentTeal)
            .cornerRadius(CornerRadius.medium)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
/// 次要按钮样式：白色背景 + 缩放反馈
struct SecondaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Fonts.bodyRegular())
            .foregroundColor(isDisabled ? Colors.textQuaternary : Colors.textInk)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Text Button Style
/// 文本按钮样式：无背景 + 轻微缩放
struct TextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Button Style
/// 卡片按钮样式：用于可点击的卡片 + 缩放反馈
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extension
extension View {
    /// 应用缩放按钮样式
    func scaleButtonStyle(scale: CGFloat = 0.95) -> some View {
        self.buttonStyle(ScaleButtonStyle(scale: scale))
    }
    
    /// 应用主要按钮样式
    func primaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
    
    /// 应用次要按钮样式
    func secondaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isDisabled: isDisabled))
    }
    
    /// 应用文本按钮样式
    func textButtonStyle() -> some View {
        self.buttonStyle(TextButtonStyle())
    }
    
    /// 应用卡片按钮样式
    func cardButtonStyle() -> some View {
        self.buttonStyle(CardButtonStyle())
    }
}

