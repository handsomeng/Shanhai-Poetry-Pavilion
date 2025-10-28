//
//  UITextViewWrapper.swift
//  山海诗馆
//
//  UITextView 包装器 - 解决 SwiftUI TextEditor 键盘遮挡问题
//

import SwiftUI
import UIKit

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
        
        // 样式设置
        textView.font = font
        textView.textColor = textColor
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 300, right: 20)  // 🔑 大量底部内边距
        
        // 键盘设置
        textView.keyboardDismissMode = .interactive
        textView.autocorrectionType = .default  // 允许自动纠错
        textView.autocapitalizationType = .sentences  // 句子首字母大写
        
        // 初始文本设置
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.text = text
            textView.textColor = textColor
        }
        
        // 🔑 监听键盘事件
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // 避免循环更新
        if context.coordinator.isEditing {
            return
        }
        
        // 更新文本（如果来自外部）
        if textView.textColor == textColor && textView.text != text {
            textView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        var isEditing = false
        weak var textView: UITextView?
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.textView = textView
            isEditing = true
            
            // 清除占位符
            if textView.textColor == parent.placeholderColor {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 实时更新绑定的文本
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
            
            // UITextView 会自动处理光标跟随，无需手动干预
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
            self.textView = nil
            
            // 恢复占位符
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
        
        // 🔑 键盘显示时，调整内边距
        @objc func keyboardWillShow(_ notification: Notification) {
            guard let textView = textView,
                  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            // 调整 contentInset，为键盘留出空间
            let keyboardHeight = keyboardFrame.height
            textView.contentInset.bottom = keyboardHeight
            textView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
        
        @objc func keyboardWillHide(_ notification: Notification) {
            guard let textView = textView else { return }
            
            // 恢复原始 contentInset
            textView.contentInset.bottom = 300
            textView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

