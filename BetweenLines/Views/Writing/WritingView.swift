//
//  WritingView.swift
//  山海诗馆
//
//  写诗主视图：选择创作模式
//

import SwiftUI

struct WritingView: View {
    
    @StateObject private var poemManager = PoemManager.shared
    @State private var selectedMode: WritingMode?
    @State private var showingModeSelector = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 顶部标题
                        headerSection
                        
                        // 三种创作模式
                        modesSection
                        
                        Spacer()
                            .frame(height: Spacing.xl)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("写诗")
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text("选择一种创作模式，开始你的诗歌之旅")
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Modes Section
    
    private var modesSection: some View {
        VStack(spacing: Spacing.md) {
            // 自由写诗
            NavigationLink(destination: DirectWritingView()) {
                ModeCardView(
                    icon: "pencil.and.outline",
                    title: "自由写诗",
                    description: "尽情创作你此刻的山河",
                    color: Colors.accentTeal
                )
            }
            .buttonStyle(PlainButtonStyle())
            .cardButtonStyle()
            
            // 临摹写诗
            NavigationLink(destination: MimicWritingView()) {
                ModeCardView(
                    icon: "doc.on.doc",
                    title: "临摹写诗",
                    description: "临摹是进步的起点",
                    color: Color(hex: "8B7355")
                )
            }
            .buttonStyle(PlainButtonStyle())
            .cardButtonStyle()
            
            // 主题写诗
            NavigationLink(destination: ThemeWritingView()) {
                ModeCardView(
                    icon: "sparkles",
                    title: "主题写诗",
                    description: "没灵感也没关系，我给你灵感",
                    color: Color(hex: "B8860B")
                )
            }
            .buttonStyle(PlainButtonStyle())
            .cardButtonStyle()
        }
    }
    
    // MARK: - Drafts Section
    
    private var draftsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("最近草稿")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                
                Spacer()
                
                Text("\(poemManager.myDrafts.count) 篇")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
            
            ForEach(poemManager.myDrafts.prefix(3)) { draft in
                NavigationLink(destination: DirectWritingView(existingPoem: draft)) {
                    DraftCardView(poem: draft)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Mode Card View

private struct ModeCardView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
            }
            
            // 文字信息
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Fonts.titleMedium())
                    .foregroundColor(Colors.textInk)
                
                Text(description)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Colors.textSecondary)
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Draft Card View

private struct DraftCardView: View {
    let poem: Poem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(poem.title.isEmpty ? "无标题" : poem.title)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                    .lineLimit(1)
                
                Spacer()
                
                Text(poem.shortDate)
                    .font(Fonts.footnote())
                    .foregroundColor(Colors.textSecondary)
            }
            
            Text(poem.content)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 10))
                Text("\(poem.wordCount) 字")
                    .font(Fonts.footnote())
            }
            .foregroundColor(Colors.textSecondary)
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Preview

#Preview("写诗主页") {
    WritingView()
}


