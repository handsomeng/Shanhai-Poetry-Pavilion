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
    @State private var selectedTags: [String] = []
    @State private var currentPoem: Poem?
    
    // UI 状态
    @State private var showingTagPicker = false
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
                
                // 标签选择
                tagSection
                
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
        .sheet(isPresented: $showingTagPicker) {
            TagPickerSheet(selectedTags: $selectedTags)
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
    
    // MARK: - Tag Section
    
    private var tagSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("标签")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Button(action: { showingTagPicker = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("添加标签")
                    }
                    .font(Fonts.caption())
                    .foregroundColor(Colors.accentTeal)
                }
            }
            
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(selectedTags, id: \.self) { tag in
                            TagChip(tag: tag) {
                                selectedTags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
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
            selectedTags = poem.tags
            aiComment = poem.aiComment ?? ""
            currentPoem = poem
        }
    }
    
    private func saveDraft() {
        if let existing = currentPoem {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.tags = selectedTags
            poemManager.savePoem(updated)
        } else {
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: selectedTags,
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
            updated.tags = selectedTags
            poemManager.savePoem(updated)
            poemManager.publishPoem(updated)
        } else {
            let newPoem = poemManager.createDraft(
                title: title,
                content: content,
                tags: selectedTags,
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

// MARK: - Tag Chip

private struct TagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(Fonts.footnote())
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundColor(Colors.accentTeal)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(Colors.accentTeal.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Tag Picker Sheet

private struct TagPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: [String]
    
    let availableTags = ["风", "雨", "窗", "梦", "城市", "孤独", "爱", "时间", "海", "夜晚", "思念", "离别", "春天", "秋天", "回忆", "远方"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: Spacing.md) {
                        ForEach(availableTags, id: \.self) { tag in
                            Button(action: {
                                toggleTag(tag)
                            }) {
                                Text(tag)
                                    .font(Fonts.bodyRegular())
                                    .foregroundColor(selectedTags.contains(tag) ? .white : Colors.textInk)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                    .background(selectedTags.contains(tag) ? Colors.accentTeal : Colors.white)
                                    .cornerRadius(CornerRadius.medium)
                            }
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("选择标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
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


