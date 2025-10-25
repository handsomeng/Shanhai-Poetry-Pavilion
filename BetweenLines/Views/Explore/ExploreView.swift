//
//  ExploreView.swift
//  山海诗馆
//
//  赏诗主视图：浏览所有人发布的诗歌
//

import SwiftUI

struct ExploreView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State private var selectedCategory: PoemCategory?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                if squarePoems.isEmpty {
                    emptyStateView
                } else {
                    poemsListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("赏诗")
                        .font(Fonts.h2Small())
                        .foregroundColor(Colors.textInk)
                }
            }
        }
    }
    
    // MARK: - Poems List
    
    private var poemsListView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(squarePoems) { poem in
                    NavigationLink(destination: PoemDetailView(poem: poem)) {
                        PoemCard(poem: poem)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 80))
                .foregroundColor(Colors.textInk.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("广场还很空")
                    .font(Fonts.h2())
                    .foregroundColor(Colors.textInk)
                
                Text("去创作一首诗，分享到广场吧")
                    .font(Fonts.body())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var squarePoems: [Poem] {
        // 获取所有发布到广场的诗歌（包括自己和其他人的）
        return poemManager.squarePoems
    }
}

#Preview {
    ExploreView()
}
