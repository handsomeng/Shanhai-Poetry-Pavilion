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
    @State private var showingShareSheet = false
    @State private var showingCancelConfirm = false
    @State private var isKeyboardVisible = false
    @State private var showingSaveOptions = false
    @State private var isPublishing = false
    @State private var showLoginSheet = false
    
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
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
        .confirmationDialog("保存诗歌", isPresented: $showingSaveOptions) {
            Button("保存为草稿") {
                saveDraft()
            }
            Button("保存到诗集") {
                saveToCollection()
            }
            if authService.isAuthenticated {
                Button("发布到广场") {
                    publishToSquare()
                }
            } else {
                Button("登录后发布到广场") {
                    showLoginSheet = true
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("选择保存方式")
        }
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            // 保存草稿
            Button(action: saveDraft) {
                VStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                    Text("草稿")
                        .font(Fonts.caption())
                }
                .foregroundColor(Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            .disabled(content.isEmpty)
            
            // 保存到诗集
            Button(action: saveToCollection) {
                VStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 20))
                    Text("诗集")
                        .font(Fonts.caption())
                }
                .foregroundColor(Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            .disabled(content.isEmpty)
            
            // 发布到广场
            Button(action: {
                if authService.isAuthenticated {
                    publishToSquare()
                } else {
                    showLoginSheet = true
                }
            }) {
                HStack(spacing: 6) {
                    if isPublishing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("发布")
                        .fontWeight(.medium)
                }
                .font(Fonts.bodyRegular())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
            }
            .disabled(content.isEmpty || isPublishing)
        }
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
    
    /// 保存为草稿
    private func saveDraft() {
        if authService.isAuthenticated {
            // 后端草稿
            Task {
                do {
                    guard let userId = authService.currentUser?.id else { return }
                    _ = try await poemService.saveDraft(
                        authorId: userId,
                        title: title.isEmpty ? "无标题" : title,
                        content: content,
                        style: "modern"
                    )
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    print("保存草稿失败: \(error)")
                }
            }
        } else {
            // 本地草稿
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: [],
                writingMode: .direct
            )
            poemManager.savePoem(newPoem)
            dismiss()
        }
    }
    
    /// 保存到诗集（仅本地）
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
        
        // 显示分享选项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
        }
    }
    
    /// 发布到广场
    private func publishToSquare() {
        guard authService.isAuthenticated,
              let userId = authService.currentUser?.id else {
            showLoginSheet = true
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                _ = try await poemService.publishPoem(
                    authorId: userId,
                    title: title.isEmpty ? "无标题" : title,
                    content: content,
                    style: "modern"
                )
                
                await MainActor.run {
                    isPublishing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    print("发布失败: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("直接写诗") {
    NavigationStack {
        DirectWritingView()
    }
}


