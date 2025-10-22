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
    
    // 编辑状态
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var currentPoem: Poem?
    
    // UI 状态
    @State private var showingShareSheet = false
    @State private var showingCancelConfirm = false
    @State private var isKeyboardVisible = false
    
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
            Button("保存草稿") {
                // 保存诗歌但不显示分享面板
                if let existing = currentPoem {
                    var updated = existing
                    updated.title = title
                    updated.content = content
                    updated.tags = []
                    poemManager.savePoem(updated)
                } else {
                    let newPoem = poemManager.createDraft(
                        title: title,
                        content: content,
                        tags: [],
                        writingMode: .direct
                    )
                    poemManager.savePoem(newPoem)
                }
                dismiss()
            }
            Button("继续编辑", role: .cancel) {}
        } message: {
            Text("诗歌尚未保存，是否保存为草稿？")
        }
        .onAppear {
            loadExistingPoem()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let poem = currentPoem {
                ShareSheet(poem: poem)
            }
        }
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        Button(action: savePoem) {
            Text("保存")
                .font(Fonts.bodyRegular())
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
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
    
    private func savePoem() {
        if let existing = currentPoem {
            // 更新现有诗歌
            var updated = existing
            updated.title = title
            updated.content = content
            updated.tags = []
            updated.inMyCollection = true  // 保存到诗集
            poemManager.savePoem(updated)
            currentPoem = updated
        } else {
            // 创建新诗歌并保存到诗集
            var newPoem = Poem(
                title: title,
                content: content,
                authorName: poemManager.currentUserName,
                tags: [],
                writingMode: .direct,
                inMyCollection: true,  // 保存到诗集
                inSquare: false
            )
            poemManager.saveToCollection(newPoem)
            currentPoem = newPoem
        }
        
        // 保存成功后，自动显示分享选项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
        }
    }
}

// MARK: - Preview

#Preview("直接写诗") {
    NavigationStack {
        DirectWritingView()
    }
}


