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
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        // 关键设置：让系统自动处理键盘避让
        textView.keyboardDismissMode = .interactive
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        
        // 设置占位符
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // 只在文本真正改变时更新
        if textView.text != text && textView.textColor != placeholderColor {
            textView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // 清除占位符
            if textView.textColor == parent.placeholderColor {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 更新绑定的文本
            parent.text = textView.text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            // 恢复占位符
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
    }
}

