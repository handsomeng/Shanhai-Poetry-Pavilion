//
//  KeyboardObserver.swift
//  山海诗馆
//
//  键盘高度监听器
//

import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .subscribe(on: DispatchQueue.main)
            .assign(to: \.keyboardHeight, on: self)
    }
}

// ViewModifier 用于自动避让键盘
struct KeyboardAvoidanceModifier: ViewModifier {
    @StateObject private var keyboard = KeyboardObserver()
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
    }
}

extension View {
    func avoidKeyboard() -> some View {
        modifier(KeyboardAvoidanceModifier())
    }
}

