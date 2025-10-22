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
    @State private var showingAICommentSheet = false
    @State private var showingShareSheet = false
    @State private var showingCancelConfirm = false
    @State private var aiComment: String = ""
    @State private var isLoadingAI = false
    
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
                    content: $content
                )
                
                // AI 点评按钮
                aiCommentButton
                
                // 底部操作按钮
                bottomButtons
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)  // 不让键盘被自动处理，我们手动控制
        .animation(.easeOut(duration: 0.25), value: UUID())  // 平滑动画
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
        .sheet(isPresented: $showingAICommentSheet) {
            AICommentSheet(comment: aiComment)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let poem = currentPoem {
                ShareSheet(poem: poem)
            }
        }
    }
    
    // MARK: - AI Comment Button
    
    private var aiCommentButton: some View {
        Button(action: requestAIComment) {
            HStack {
                if isLoadingAI {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(isLoadingAI ? "AI 点评中..." : "获取 AI 点评")
            }
            .font(Fonts.bodyRegular())
            .foregroundColor(isLoadingAI ? Colors.textSecondary : Colors.accentTeal)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Colors.white)
            .cornerRadius(CornerRadius.medium)
        }
        .disabled(content.isEmpty || isLoadingAI)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        VStack(spacing: Spacing.sm) {
            // 保存按钮
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
            
            // 分享按钮（仅在有保存内容时显示）
            if currentPoem != nil {
                Button(action: { showingShareSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                        Text("分享")
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.sm)
                }
            }
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
            aiComment = poem.aiComment ?? ""
            currentPoem = poem
        }
    }
    
    private func savePoem() {
        if let existing = currentPoem {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.tags = []
            poemManager.savePoem(updated)
            currentPoem = updated
        } else {
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: [],
                writingMode: .direct
            )
            currentPoem = newPoem
            poemManager.savePoem(newPoem)
        }
        
        // 保存成功后，自动显示分享选项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
        }
    }
    
    private func requestAIComment() {
        guard !content.isEmpty else { return }
        
        isLoadingAI = true
        
        Task {
            do {
                let comment = try await AIService.shared.getPoemComment(content: content)
                await MainActor.run {
                    aiComment = comment
                    isLoadingAI = false
                    showingAICommentSheet = true
                    
                    // 保存 AI 点评到诗歌
                    if let existing = currentPoem {
                        poemManager.addAIComment(to: existing, comment: comment)
                    }
                }
            } catch {
                await MainActor.run {
                    aiComment = "AI 点评获取失败，请稍后重试"
                    isLoadingAI = false
                    showingAICommentSheet = true
                }
            }
        }
    }
}

// MARK: - AI Comment Sheet

private struct AICommentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let comment: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(Colors.accentTeal)
                            Text("AI 诗评")
                                .font(Fonts.titleMedium())
                                .foregroundColor(Colors.textInk)
                        }
                        
                        Text(comment)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textInk)
                            .lineSpacing(8)
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
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


