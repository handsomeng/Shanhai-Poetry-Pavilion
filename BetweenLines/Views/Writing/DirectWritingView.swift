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
    @StateObject private var poemService = PoemService.shared
    private let identityService = UserIdentityService()
    
    // 编辑状态
    @State private var title: String = ""
    @State private var content: String = ""
    // UI 状态
    @State private var showingCancelConfirm = false
    @State private var hasSaved = false  // 跟踪是否已保存
    @State private var autoSaveTimer: Timer?  // 自动保存定时器
    // 草稿 ID（整个写作过程使用同一个 ID）
    @State private var draftId: String
    
    // 初始化（可选：编辑现有诗歌）
    let existingPoem: Poem?
    
    init(existingPoem: Poem? = nil) {
        self.existingPoem = existingPoem
        // 如果是编辑现有诗歌，使用现有ID；否则创建新ID
        if let poem = existingPoem {
            _draftId = State(initialValue: poem.id)
        } else {
            _draftId = State(initialValue: UUID().uuidString)
        }
    }
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea(edges: .top)  // 只忽略顶部，让键盘能推动界面
            
            // 诗歌编辑器（全屏，不显示字数统计）
            PoemEditorView(
                title: $title,
                content: $content,
                showWordCount: false
            )
        }
        .onAppear {
            loadExistingPoem()
            startAutoSave()
        }
        .onDisappear {
            stopAutoSave()
            // 退出前保存一次
            if !content.isEmpty && !hasSaved {
                autoSaveDraft()
            }
        }
        .onChange(of: content) { oldValue, newValue in
            // 内容变化时重置定时器
            if !newValue.isEmpty {
                resetAutoSaveTimer()
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveToCollection()
                }
                .disabled(content.isEmpty)
                .foregroundColor(content.isEmpty ? Colors.textSecondary : Colors.accentTeal)
            }
        }
        .alert("确认取消", isPresented: $showingCancelConfirm) {
            Button("放弃", role: .destructive) {
                dismiss()
            }
            Button("自动保存") {
                // 使用 autoSaveDraft() 方法保存诗歌（会更新现有诗歌或创建新诗歌）
                autoSaveDraft()
                ToastManager.shared.showSuccess("已自动保存")
                dismiss()
            }
            Button("继续编辑", role: .cancel) {}
        } message: {
            Text("诗歌尚未保存，是否自动保存？")
        }
        .onAppear {
            loadExistingPoem()
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
        // 如果已保存，直接关闭
        if hasSaved {
            dismiss()
            return
        }
        
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
        }
    }
    
    // MARK: - Auto Save
    
    /// 启动自动保存
    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            autoSaveDraft()
        }
    }
    
    /// 停止自动保存
    private func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    /// 重置自动保存定时器
    private func resetAutoSaveTimer() {
        stopAutoSave()
        startAutoSave()
    }
    
    /// 自动保存诗歌（统一为已完成状态）
    private func autoSaveDraft() {
        // 只有在有内容且未手动保存时才自动保存
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !hasSaved else { return }
        
        // 检查诗歌是否已存在
        if let existingPoem = poemManager.getPoem(by: draftId) {
            // ✅ 更新现有诗歌
            var updatedPoem = existingPoem
            updatedPoem.title = title.isEmpty ? "无标题" : title
            updatedPoem.content = content
            updatedPoem.inMyCollection = true  // 统一为已完成状态
            updatedPoem.updatedAt = Date()
            poemManager.savePoem(updatedPoem)
            print("📝 [DirectWriting] 自动保存 - 已更新诗歌: \(draftId)")
        } else {
            // ✅ 首次创建诗歌（使用固定的 draftId）
            let poem = Poem(
                id: draftId,  // 使用固定ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,  // 设置 userId
                tags: [],
                writingMode: .direct,
                inMyCollection: true,  // 统一为已完成状态
                inSquare: false
            )
            poemManager.savePoem(poem)  // savePoem 现在会自动添加新诗歌
            print("📝 [DirectWriting] 自动保存 - 已创建诗歌: \(draftId)")
        }
    }
    
    // MARK: - Save Actions
    
    /// 保存诗歌（统一保存，不再区分草稿和诗集）
    private func saveToCollection() {
        // 检查是否有对应的诗歌
        if let existingPoem = poemManager.getPoem(by: draftId) {
            // ✅ 更新现有诗歌
            var poemToSave = existingPoem
            poemToSave.title = title.isEmpty ? "无标题" : title
            poemToSave.content = content
            poemToSave.inMyCollection = true  // 统一为已完成状态
            poemToSave.updatedAt = Date()
            
            let saved = poemManager.saveToCollection(poemToSave)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经保存过了")
                return
            }
            print("📚 [DirectWriting] 已更新诗歌: \(draftId)")
        } else {
            // ✅ 创建新诗歌
            let newPoem = Poem(
                id: draftId,  // 使用同一个ID
                title: title.isEmpty ? "无标题" : title,
                content: content,
                authorName: poemManager.currentUserName,
                userId: identityService.userId,
                tags: [],
                writingMode: .direct,
                inMyCollection: true,  // 统一为已完成状态
                inSquare: false
            )
            
            let saved = poemManager.saveToCollection(newPoem)
            if !saved {
                ToastManager.shared.showInfo("这首诗已经保存过了")
                return
            }
            print("📚 [DirectWriting] 已创建新诗歌: \(draftId)")
        }
        
        hasSaved = true  // 标记已保存
        
        // Toast 提示
        ToastManager.shared.showSuccess("已保存")
        
        // 1秒后返回诗集
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview("直接写诗") {
    NavigationStack {
        DirectWritingView()
    }
}


