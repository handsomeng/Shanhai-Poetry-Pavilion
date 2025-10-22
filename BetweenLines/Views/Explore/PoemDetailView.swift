//
//  PoemDetailView.swift
//  山海诗馆
//
//  诗歌详情页
//

import SwiftUI

struct PoemDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var interactionService = InteractionService.shared
    @StateObject private var poemService = PoemService.shared
    
    @State var poem: Poem
    @State private var likeScale: CGFloat = 1.0
    @State private var favoriteScale: CGFloat = 1.0
    @State private var showingDeleteAlert = false
    @State private var showLoginSheet = false
    @State private var isLiked = false
    @State private var isFavorited = false
    @State private var likeCount = 0
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 诗歌头部信息
                    headerSection
                    
                    // 诗歌内容
                    contentSection
                    
                    // AI 点评
                    if let aiComment = poem.aiComment {
                        aiCommentSection(comment: aiComment)
                    }
                    
                    // 底部操作区
                    actionSection
                    
                    Spacer()
                        .frame(height: Spacing.xl)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
            }
        }
        .navigationTitle("诗歌详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if poem.authorName == poemManager.currentUserName {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(Colors.error)
                    }
                }
            }
        }
        .alert("从广场删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deletePoem()
            }
        } message: {
            Text("确定要从广场删除这首诗吗？删除后其他用户将无法看到。")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
        .task {
            loadInteractionStatus()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(poem.title)
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            HStack {
                Text(poem.authorName)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Text(poem.formattedDate)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        Text(poem.content)
            .font(Fonts.bodyPoem())
            .foregroundColor(Colors.textInk)
            .lineSpacing(10)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
    }
    
    // MARK: - AI Comment Section
    
    private func aiCommentSection(comment: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Colors.accentTeal)
                Text("AI 诗评")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
            }
            
            Text(comment)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .lineSpacing(6)
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
    }
    
    // MARK: - Action Section
    
    private var actionSection: some View {
        HStack(spacing: Spacing.xxl) {
            Spacer()
            
            // 点赞
            Button(action: handleLike) {
                VStack(spacing: 8) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 28))
                        .foregroundColor(isLiked ? .red : Colors.textSecondary)
                        .scaleEffect(likeScale)
                    
                    Text("\(likeCount)")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                        .contentTransition(.numericText())
                }
            }
            
            // 收藏
            Button(action: handleFavorite) {
                VStack(spacing: 8) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .font(.system(size: 28))
                        .foregroundColor(isFavorited ? Color(hex: "FFD700") : Colors.textSecondary)
                        .scaleEffect(favoriteScale)
                    
                    Text(isFavorited ? "已收藏" : "收藏")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
    }
    
    // MARK: - Actions
    
    /// 加载点赞和收藏状态
    private func loadInteractionStatus() {
        // 初始化点赞数
        likeCount = poem.squareLikeCount
        
        guard authService.isAuthenticated,
              let userId = authService.currentUser?.id else {
            return
        }
        
        Task {
            do {
                // 检查点赞状态
                let liked = try await interactionService.checkLiked(userId: userId, poemId: poem.id)
                // 检查收藏状态
                let favorited = try await interactionService.checkFavorited(userId: userId, poemId: poem.id)
                
                await MainActor.run {
                    isLiked = liked
                    isFavorited = favorited
                }
            } catch {
                print("加载互动状态失败: \(error)")
            }
        }
    }
    
    /// 处理点赞
    private func handleLike() {
        guard authService.isAuthenticated,
              let userId = authService.currentUser?.id else {
            showLoginSheet = true
            return
        }
        
        // 触发动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            likeScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                likeScale = 1.0
            }
        }
        
        // 立即更新 UI
        let wasLiked = isLiked
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
        // 调用后端 API
        Task {
            do {
                try await interactionService.toggleLike(userId: userId, poemId: poem.id)
            } catch {
                // 失败时回滚
                await MainActor.run {
                    isLiked = wasLiked
                    likeCount += wasLiked ? 1 : -1
                    toastManager.showError("操作失败")
                }
            }
        }
    }
    
    /// 处理收藏
    private func handleFavorite() {
        guard authService.isAuthenticated,
              let userId = authService.currentUser?.id else {
            showLoginSheet = true
            return
        }
        
        // 触发动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            favoriteScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                favoriteScale = 1.0
            }
        }
        
        // 立即更新 UI
        let wasFavorited = isFavorited
        isFavorited.toggle()
        
        if isFavorited {
            toastManager.showSuccess("已添加到收藏")
        } else {
            toastManager.showSuccess("已取消收藏")
        }
        
        // 调用后端 API
        Task {
            do {
                try await interactionService.toggleFavorite(userId: userId, poemId: poem.id)
            } catch {
                // 失败时回滚
                await MainActor.run {
                    isFavorited = wasFavorited
                    toastManager.showError("操作失败")
                }
            }
        }
    }
    
    /// 删除诗歌
    private func deletePoem() {
        if authService.isAuthenticated {
            // 后端删除
            Task {
                do {
                    try await poemService.deletePoem(id: poem.id)
                    await MainActor.run {
                        toastManager.showSuccess("已删除")
                        dismiss()
                    }
                } catch {
                    await MainActor.run {
                        toastManager.showError("删除失败")
                    }
                }
            }
        } else {
            // 本地删除
            poemManager.removeFromSquare(poem)
            toastManager.showSuccess("已从广场删除")
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PoemDetailView(poem: .example)
    }
}


