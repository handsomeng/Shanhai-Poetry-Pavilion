//
//  DirectWritingView.swift
//  山海诗馆
//
//  直接写诗模式：自由创作
//

import SwiftUI

struct DirectWritingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    
    // 编辑状态
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var currentPoem: Poem?
    
    // UI 状态
    @State private var showingCancelConfirm = false
    @State private var isKeyboardVisible = false
    @State private var showSuccessView = false
    @State private var generatedImage: UIImage?
    
    // 初始化（可选：编辑现有诗歌）
    let existingPoem: Poem?
    
    init(existingPoem: Poem? = nil) {
        self.existingPoem = existingPoem
    }
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea(edges: .top)  // 只忽略顶部，让键盘能推动界面
            
            VStack(spacing: 0) {
                // 诗歌编辑器
                PoemEditorView(
                    title: $title,
                    content: $content,
                    showWordCount: !isKeyboardVisible
                )
                
                // 底部操作按钮（键盘弹起时隐藏）
                if !isKeyboardVisible {
                    bottomButtons
                }
            }
        }
        .onAppear {
            // 监听键盘显示/隐藏
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    isKeyboardVisible = true
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    isKeyboardVisible = false
                }
            }
        }
        .navigationTitle("直接写诗")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    handleCancel()
                }
            }
        }
        .alert("确认取消", isPresented: $showingCancelConfirm) {
            Button("放弃", role: .destructive) {
                dismiss()
            }
            Button("自动保存草稿") {
                // 保存草稿
                let draft = poemManager.createDraft(
                    title: title,
                    content: content,
                    tags: [],
                    writingMode: .direct
                )
                poemManager.savePoem(draft)
                ToastManager.shared.showSuccess("已自动保存到草稿")
                dismiss()
            }
            Button("继续编辑", role: .cancel) {}
        } message: {
            Text("诗歌尚未保存，是否保存为草稿？")
        }
        .onAppear {
            loadExistingPoem()
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            if let poem = currentPoem, let image = generatedImage {
                PoemSuccessView(poem: poem, poemImage: image)
            }
        }
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        Button(action: saveToCollection) {
            Text("保存到诗集")
                .font(Fonts.bodyLarge())
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
        }
        .disabled(content.isEmpty)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Actions
    
    private func handleCancel() {
        // 如果有内容未保存，显示确认弹窗
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showingCancelConfirm = true
        } else {
            dismiss()
        }
    }
    
    private func loadExistingPoem() {
        if let poem = existingPoem {
            title = poem.title
            content = poem.content
            currentPoem = poem
        }
    }
    
    // MARK: - Save Actions
    
    /// 保存到诗集
    private func saveToCollection() {
        let newPoem = Poem(
            title: title.isEmpty ? "无标题" : title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .direct,
            inMyCollection: true,
            inSquare: false
        )
        poemManager.saveToCollection(newPoem)
        currentPoem = newPoem
        
        // 生成分享图片
        generatedImage = PoemImageGenerator.generate(poem: newPoem)
        
        // Toast 提示
        ToastManager.shared.showSuccess("已保存到你的诗集")
        
        // 显示成功页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showSuccessView = true
        }
    }
}

// MARK: - Preview

#Preview("直接写诗") {
    NavigationStack {
        DirectWritingView()
    }
}


