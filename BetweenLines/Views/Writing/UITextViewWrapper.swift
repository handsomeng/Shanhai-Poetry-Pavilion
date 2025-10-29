//
//  UITextViewWrapper.swift
//  山海诗馆
//
//  UITextView 包装器 - iOS 原生的优雅键盘处理方案
//
//  核心原理：
//  1. UITextView 本身就是 UIScrollView，可以自己滚动
//  2. 监听键盘通知，调整 contentInset.bottom
//  3. UITextView 会自动滚动到光标位置
//  4. 不需要外层处理任何逻辑
//

import SwiftUI
import UIKit
import Combine

/// UITextView 的 SwiftUI 包装器
struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let font: UIFont
    let textColor: UIColor
    let placeholderColor: UIColor
    
    init(
        text: Binding<String>,
        placeholder: String = "在这里写下你的诗...",
        font: UIFont = .systemFont(ofSize: 17),
        textColor: UIColor = UIColor(Colors.textInk),
        placeholderColor: UIColor = UIColor(Colors.textSecondary.opacity(0.5))
    ) {
        self._text = text
        self.placeholder = placeholder
        self.font = font
        self.textColor = textColor
        self.placeholderColor = placeholderColor
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        // 📝 样式设置
        textView.font = font
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        // ⌨️ 键盘设置
        textView.keyboardDismissMode = .interactive  // 可以拖动键盘关闭
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        
        // 🎨 初始文本
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.text = text
            textView.textColor = textColor
        }
        
        // 🔑 关键：监听键盘通知
        context.coordinator.setupKeyboardObservers(for: textView)
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // 避免在编辑时更新，防止光标跳动
        if context.coordinator.isEditing {
            return
        }
        
        // 只有在文本真正不同时才更新
        if textView.textColor == textColor && textView.text != text {
            textView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        var isEditing = false
        
        private var keyboardWillShowCancellable: AnyCancellable?
        private var keyboardWillHideCancellable: AnyCancellable?
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        // 🔑 设置键盘监听器
        func setupKeyboardObservers(for textView: UITextView) {
            // 键盘即将显示
            keyboardWillShowCancellable = NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification -> CGFloat? in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return nil
                    }
                    return keyboardFrame.height
                }
                .sink { [weak textView] keyboardHeight in
                    guard let textView = textView else { return }
                    
                    // 🎯 核心：调整 contentInset，为键盘留出空间
                    var contentInset = textView.contentInset
                    contentInset.bottom = keyboardHeight
                    textView.contentInset = contentInset
                    
                    // 同时调整滚动条位置
                    var scrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                    scrollIndicatorInsets.bottom = keyboardHeight
                    textView.verticalScrollIndicatorInsets = scrollIndicatorInsets
                }
            
            // 键盘即将隐藏
            keyboardWillHideCancellable = NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .sink { [weak textView] _ in
                    guard let textView = textView else { return }
                    
                    // 恢复原始 inset
                    var contentInset = textView.contentInset
                    contentInset.bottom = 0
                    textView.contentInset = contentInset
                    
                    var scrollIndicatorInsets = textView.verticalScrollIndicatorInsets
                    scrollIndicatorInsets.bottom = 0
                    textView.verticalScrollIndicatorInsets = scrollIndicatorInsets
                }
        }
        
        // MARK: - UITextViewDelegate
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            
            // 清除占位符
            if textView.textColor == parent.placeholderColor {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 实时更新 SwiftUI 绑定
            parent.text = textView.text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            
            // 恢复占位符
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
        
        deinit {
            // 清理订阅
            keyboardWillShowCancellable?.cancel()
            keyboardWillHideCancellable?.cancel()
        }
    }
}
