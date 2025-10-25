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
        // 初始化点赞数和本地状态
        likeCount = poem.squareLikeCount
        isLiked = poem.isLiked
        // 收藏状态从 PoemManager 获取
        isFavorited = poemManager.myCollection.contains { $0.id == poem.id }
    }
    
    /// 处理点赞
    private func handleLike() {
        // 触发动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            likeScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                likeScale = 1.0
            }
        }
        
        // 切换点赞状态（本地）
        poemManager.toggleLike(for: poem)
        
        // 更新 UI
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
    }
    
    /// 处理收藏
    private func handleFavorite() {
        // 触发动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            favoriteScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                favoriteScale = 1.0
            }
        }
        
        // 切换收藏状态
        isFavorited.toggle()
        
        if isFavorited {
            // 添加到诗集
            poemManager.saveToCollection(poem)
            toastManager.showSuccess("已添加到收藏")
        } else {
            // 从诗集移除
            poemManager.removeFromCollection(poem)
            toastManager.showSuccess("已取消收藏")
        }
    }
    
    /// 删除诗歌
    private func deletePoem() {
        // 从广场删除
        poemManager.removeFromSquare(poem)
        toastManager.showSuccess("已从广场删除")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PoemDetailView(poem: .example)
    }
}


