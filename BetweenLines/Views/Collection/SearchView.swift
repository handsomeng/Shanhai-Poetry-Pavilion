//
//  SearchView.swift
//  山海诗馆
//
//  诗歌搜索界面
//  - 搜索标题和内容
//  - 搜索历史
//  - 实时搜索结果
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索框
                searchBar
                
                // 搜索结果
                searchResults
            }
            .background(Colors.backgroundCream)
            .navigationTitle("搜索诗歌")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
            .onAppear {
                isSearchFieldFocused = true
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Colors.textTertiary)
            
            TextField("搜索标题或内容", text: $searchText)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
                .focused($isSearchFieldFocused)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.textTertiary)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Colors.white)
        .cornerRadius(CornerRadius.small)
        .padding(Spacing.lg)
    }
    
    // MARK: - Search Results
    
    private var searchResults: some View {
        Group {
            if searchText.isEmpty {
                emptySearchView
            } else if filteredPoems.isEmpty {
                noResultsView
            } else {
                resultsList
            }
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Colors.textTertiary)
            
            Text("输入关键词搜索诗歌")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
            
            Spacer()
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Colors.textTertiary)
            
            Text("没有找到相关诗歌")
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
            
            Text("试试其他关键词")
                .font(Fonts.caption())
                .foregroundColor(Colors.textTertiary)
            
            Spacer()
        }
    }
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(filteredPoems) { poem in
                    NavigationLink(destination: MyPoemDetailView(poem: poem, isDraft: isDraft(poem))) {
                        PoemCard(poem: poem, isNew: false)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Spacing.lg)
        }
    }
    
    // MARK: - Filtered Poems
    
    private var filteredPoems: [Poem] {
        let lowercasedQuery = searchText.lowercased()
        return poemManager.allPoems.filter { poem in
            poem.title.lowercased().contains(lowercasedQuery) ||
            poem.content.lowercased().contains(lowercasedQuery)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 判断是否是草稿
    private func isDraft(_ poem: Poem) -> Bool {
        !poem.inMyCollection && !poem.inSquare
    }
}

// MARK: - Preview

#Preview {
    SearchView()
}

