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
    @State private var showingSaveAlert = false
    @State private var showingPublishAlert = false
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
                .ignoresSafeArea()
            
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
        .navigationTitle("直接写诗")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadExistingPoem()
        }
        .sheet(isPresented: $showingAICommentSheet) {
            AICommentSheet(comment: aiComment)
        }
        .alert("保存草稿", isPresented: $showingSaveAlert) {
            Button("确定") {}
        } message: {
            Text("诗歌已保存为草稿")
        }
        .alert("发布成功", isPresented: $showingPublishAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("你的诗歌已发布到广场")
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
        HStack(spacing: Spacing.md) {
            // 保存草稿
            Button(action: saveDraft) {
                Text("保存草稿")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
            }
            
            // 发布
            Button(action: publishPoem) {
                Text("发布")
                    .font(Fonts.bodyRegular())
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Colors.accentTeal)
                    .cornerRadius(CornerRadius.medium)
            }
            .disabled(content.isEmpty)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.backgroundCream)
    }
    
    // MARK: - Actions
    
    private func loadExistingPoem() {
        if let poem = existingPoem {
            title = poem.title
            content = poem.content
            aiComment = poem.aiComment ?? ""
            currentPoem = poem
        }
    }
    
    private func saveDraft() {
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
            currentPoem = newPoem
        }
        showingSaveAlert = true
    }
    
    private func publishPoem() {
        if let existing = currentPoem {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.tags = []
            poemManager.savePoem(updated)
            poemManager.publishPoem(updated)
        } else {
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: [],
                writingMode: .direct
            )
            poemManager.publishPoem(newPoem)
        }
        showingPublishAlert = true
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


