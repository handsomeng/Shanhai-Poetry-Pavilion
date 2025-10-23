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
    @StateObject private var authService = AuthService.shared
    @StateObject private var poemService = PoemService.shared
    @StateObject private var toastManager = ToastManager.shared
    
    let poem: Poem
    let isDraft: Bool // 是否是草稿
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    
    @State private var showingDeleteAlert = false
    @State private var showingPublishSheet = false
    @State private var isPublishing = false
    
    @State private var showSuccessView = false
    @State private var generatedImage: UIImage?
    
    @State private var showLoginSheet = false
    
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
            
            if isEditing {
                editingView
            } else {
                detailView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        // 恢复原内容
                        editedTitle = poem.title
                        editedContent = poem.content
                        isEditing = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            if let image = generatedImage {
                PoemSuccessView(poem: poem, poemImage: image)
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
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
    
    // MARK: - Detail View（只读）
    
    private var detailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // 标题
                if !poem.title.isEmpty {
                    Text(poem.title)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                }
                
                // 内容
                Text(poem.content)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(8)
                
                Spacer(minLength: 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xl)
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtons
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
                    
                    // 内容输入
                    TextEditor(text: $editedContent)
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Colors.textInk)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 400)
                        .padding(.horizontal, Spacing.lg)
                }
            }
            
            // 编辑时的底部按钮
            editBottomButtons
        }
    }
    
    // MARK: - Bottom Buttons（只读模式）
    
    private var bottomButtons: some View {
        VStack(spacing: Spacing.sm) {
            if isDraft {
                // 草稿：只显示"保存到诗集"
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
            } else {
                // 诗集：显示3个按钮
                HStack(spacing: Spacing.md) {
                    // 编辑
                    Button {
                        isEditing = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("编辑")
                        }
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Colors.white)
                        .cornerRadius(CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(Colors.textSecondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // 发布到广场
                    Button(action: publishToSquare) {
                        HStack {
                            if isPublishing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: poem.inSquare ? "checkmark.circle.fill" : "paperplane.fill")
                                Text(poem.inSquare ? "已发布" : "发布")
                            }
                        }
                        .font(Fonts.bodyRegular())
                        .foregroundColor(poem.inSquare ? Colors.textSecondary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(poem.inSquare ? Colors.white : Colors.accentTeal)
                        .cornerRadius(CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(poem.inSquare ? Colors.border : Color.clear, lineWidth: 1)
                        )
                    }
                    .disabled(poem.inSquare || isPublishing)
                }
                
                // 删除按钮（独立一行）
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("删除")
                    }
                    .font(Fonts.bodyRegular())
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Colors.white)
                    .cornerRadius(CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
    }
    
    // MARK: - Bottom Buttons（编辑模式）
    
    private var editBottomButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            if editedTitle == poem.title && editedContent == poem.content {
                // 未修改：显示"退出"
                Button(action: {
                    isEditing = false
                }) {
                    Text("退出")
                        .font(Fonts.bodyLarge())
                        .foregroundColor(Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                }
            } else {
                // 已修改：显示"保存"
                Button(action: saveEdits) {
                    Text("保存")
                        .font(Fonts.bodyLarge())
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Colors.accentTeal)
                        .cornerRadius(CornerRadius.medium)
                }
                .disabled(editedContent.isEmpty)
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
        .background(Colors.white)
    }
    
    // MARK: - Actions
    
    /// 保存编辑
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
        
        // 生成图片
        generatedImage = PoemImageGenerator.generate(poem: updatedPoem)
        
        // Toast提示
        ToastManager.shared.showSuccess("已保存")
        
        // 退出编辑模式
        isEditing = false
        
        // 显示成功页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showSuccessView = true
        }
    }
    
    /// 草稿保存到诗集
    private func saveToCollection() {
        var updatedPoem = poem
        updatedPoem.inMyCollection = true
        poemManager.savePoem(updatedPoem)
        
        // 生成图片
        generatedImage = PoemImageGenerator.generate(poem: updatedPoem)
        
        // Toast提示
        ToastManager.shared.showSuccess("已保存到你的诗集")
        
        // 显示成功页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showSuccessView = true
        }
    }
    
    /// 发布到广场
    private func publishToSquare() {
        guard authService.isAuthenticated else {
            showLoginSheet = true
            return
        }
        
        guard let userId = authService.currentUser?.id else {
            ToastManager.shared.showError("用户信息获取失败")
            return
        }
        
        if poem.inSquare {
            ToastManager.shared.showInfo("已发布到广场")
            return
        }
        
        isPublishing = true
        
        Task {
            do {
                _ = try await poemService.publishPoem(
                    authorId: userId,
                    title: poem.title,
                    content: poem.content,
                    style: "modern"
                )
                
                await MainActor.run {
                    isPublishing = false
                    
                    // 更新本地状态
                    var updatedPoem = poem
                    updatedPoem.auditStatus = .pending
                    updatedPoem.inSquare = false // 审核中不算在广场
                    poemManager.savePoem(updatedPoem)
                    
                    ToastManager.shared.showSuccess("已提交审核，请耐心等待")
                    
                    // 返回上一页
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPublishing = false
                    ToastManager.shared.showError("发布失败：\(error.localizedDescription)")
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

