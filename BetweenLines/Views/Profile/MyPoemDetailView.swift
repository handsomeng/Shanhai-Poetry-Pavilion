//
//  MyPoemDetailView.swift
//  山海诗馆
//
//  诗集/草稿的详情页（支持编辑、删除、发布）
//

import SwiftUI

struct MyPoemDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var poemService = PoemService.shared
    @StateObject private var toastManager = ToastManager.shared
    
    let poem: Poem
    let isDraft: Bool // 是否是草稿
    
    @State private var editedTitle: String
    @State private var editedContent: String
    
    @State private var showingDeleteAlert = false
    @State private var isPublishing = false
    
    @State private var showSuccessView = false
    @State private var generatedImage: UIImage?
    
    init(poem: Poem, isDraft: Bool = false) {
        self.poem = poem
        self.isDraft = isDraft
        _editedTitle = State(initialValue: poem.title)
        _editedContent = State(initialValue: poem.content)
    }
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            editingView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.red)
                }
            }
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            if let image = generatedImage {
                PoemSuccessView(poem: poem, poemImage: image)
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deletePoem()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后无法恢复")
        }
    }
    
    // MARK: - Editing View
    
    private var editingView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // 标题输入
                    TextField("标题（选填）", text: $editedTitle)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                        .onChange(of: editedTitle) { _ in
                            saveEdits()
                        }
                    
                    // 内容输入
                    TextEditor(text: $editedContent)
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .scrollContentBackground(.hidden)
                        .lineSpacing(8)
                        .frame(minHeight: 400)
                        .padding(.horizontal, Spacing.lg)
                        .onChange(of: editedContent) { _ in
                            saveEdits()
                        }
                }
            }
            
            // 底部发布按钮
            publishButton
        }
    }
    
    // MARK: - Publish Button（底部细条按钮）
    
    private var publishButton: some View {
        VStack(spacing: 0) {
            // 分隔线
            Divider()
            
            // 发布按钮
            Button(action: publishToSquare) {
                HStack(spacing: 6) {
                    if isPublishing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(poem.inSquare ? Colors.textSecondary : Colors.accentTeal)
                    } else {
                        Image(systemName: poem.inSquare ? "checkmark.circle.fill" : "square.and.arrow.up")
                            .font(.system(size: 14))
                    }
                    
                    Text(poem.inSquare ? "已发布到广场" : "发布到广场")
                        .font(.system(size: 15))
                }
                .foregroundColor(poem.inSquare ? Colors.textSecondary : Colors.accentTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .disabled(poem.inSquare || isPublishing)
        }
        .background(Colors.white)
    }
    
    // MARK: - Actions
    
    /// 保存编辑（实时自动保存）
    private func saveEdits() {
        var updatedPoem = poem
        updatedPoem.title = editedTitle
        updatedPoem.content = editedContent
        updatedPoem.updatedAt = Date()
        
        // 如果已发布，需要重新审核
        if poem.inSquare {
            updatedPoem.auditStatus = .pending
            updatedPoem.hasUnpublishedChanges = true
        }
        
        poemManager.savePoem(updatedPoem)
    }
    
    /// 发布到广场（本地版本）
    private func publishToSquare() {
        // 检查是否已发布
        if poem.inSquare {
            return
        }
        
        // 先保存当前编辑
        saveEdits()
        
        isPublishing = true
        
        Task {
            do {
                print("🚀 [MyPoemDetailView] 开始发布到广场...")
                
                // 使用 PoemManager 发布到本地广场
                try poemManager.publishToSquare(poem)
                
                print("✅ [MyPoemDetailView] 发布成功！")
                
                await MainActor.run {
                    isPublishing = false
                    ToastManager.shared.showSuccess("已发布到广场！")
                    
                    // 返回上一页
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            } catch {
                print("❌ [MyPoemDetailView] 发布失败：\(error)")
                
                await MainActor.run {
                    isPublishing = false
                    ToastManager.shared.showError(error.localizedDescription)
                }
            }
        }
    }
    
    /// 删除诗歌
    private func deletePoem() {
        poemManager.deletePoem(poem)
        ToastManager.shared.showSuccess("已删除")
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MyPoemDetailView(
            poem: Poem(
                title: "夜思",
                content: "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡",
                authorName: "诗人",
                tags: [],
                writingMode: .direct
            )
        )
    }
}

