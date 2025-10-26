//
//  MyPoemDetailView.swift
//  山海诗馆
//
//  诗集/草稿的详情页（支持编辑、删除、分享）
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
    @State private var showingShareSheet = false
    
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
                HStack(spacing: 12) {
                    // 分享按钮
                    Button(action: sharePoem) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Colors.accentTeal)
                            .frame(width: 44, height: 32)
                    }
                    
                    // 删除按钮
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.red)
                            .frame(width: 44, height: 32)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let latestPoem = poemManager.allPoems.first(where: { $0.id == poem.id }) {
                ShareSheet(poem: latestPoem)
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
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 标题输入
                TextField("标题（选填）", text: $editedTitle)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .padding(.top, Spacing.lg)
                    .onChange(of: editedTitle) {
                        saveEdits()
                    }
                
                // 内容输入
                TextEditor(text: $editedContent)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .lineSpacing(8)
                    .frame(minHeight: 300)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl) // 确保内容不被 Tab Bar 遮挡
        }
    }
    
    // MARK: - Actions
    
    /// 保存编辑（实时自动保存）
    private func saveEdits() {
        var updatedPoem = poem
        updatedPoem.title = editedTitle
        updatedPoem.content = editedContent
        updatedPoem.updatedAt = Date()
        
        // 保存本地修改
        // 因为本地和广场共享同一首诗（通过 poem.id 关联）
        
        poemManager.savePoem(updatedPoem)
    }
    
    /// 分享诗歌
    private func sharePoem() {
        // 先保存当前编辑
        saveEdits()
        
        // 显示分享界面
        showingShareSheet = true
    }
    
    /// 诗歌图片模板（纯模板，用于生成图片）
    @MainActor
    private func poemTemplateForImage(poem: Poem) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 32, weight: .thin, design: .serif))
                    .foregroundColor(Color(hex: "0A0A0A"))
                    .tracking(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 正文
            Text(poem.content)
                .font(.system(size: 20, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "4A4A4A"))
                .lineSpacing(18)
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
                .frame(height: 32)
            
            // 底部信息
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(hex: "E5E5E5"))
                
                // 第一行：第 X 首诗
                Text("第 \(poemManager.myCollection.count) 首诗")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "ABABAB"))
                    .tracking(1.5)
                
                // 第二行：称号 · 作者名
                HStack(spacing: 4) {
                    Text(poemManager.currentPoetTitle.displayName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "6A6A6A"))
                    
                    Text("·")
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                    
                    Text(poem.authorName)
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(Color(hex: "ABABAB"))
                }
                
                // 第三行：山海诗馆
                Text("山海诗馆")
                    .font(.system(size: 12, weight: .ultraLight, design: .serif))
                    .foregroundColor(Color(hex: "ABABAB"))
                    .tracking(2)
            }
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 72)
        .frame(width: 400)
        .background(Color.white)
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

