//
//  ThemeWritingView.swift
//  山海诗馆
//
//  主题写诗模式：选择意象主题激发灵感
//

import SwiftUI

struct ThemeWritingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    
    @State private var selectedTheme: String?
    @State private var title = ""
    @State private var content = ""
    @State private var aiSuggestion = ""
    @State private var isLoadingAI = false
    @State private var showingSuggestion = false
    @State private var currentPoem: Poem?
    @State private var showingShareSheet = false
    @State private var isKeyboardVisible = false
    
    let themes = ["风", "雨", "窗", "梦", "城市", "孤独", "爱", "时间", "海", "夜晚"]
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTheme == nil {
                    themeSelectionView
                } else {
                    writingView
                }
            }
        }
        .navigationTitle("主题写诗")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            if selectedTheme != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("换主题") {
                        selectedTheme = nil
                        title = ""
                        content = ""
                        aiSuggestion = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Theme Selection View
    
    private var themeSelectionView: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("选择一个主题")
                    .font(Fonts.titleLarge())
                    .foregroundColor(Colors.textInk)
                
                Text("围绕主题意象展开创作")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(.top, Spacing.xl)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.lg) {
                ForEach(themes, id: \.self) { theme in
                    Button(action: {
                        selectTheme(theme)
                    }) {
                        ThemeCard(theme: theme)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Writing View
    
    private var writingView: some View {
        VStack(spacing: 0) {
            // 主题显示
            if let theme = selectedTheme {
                themeHeader(theme: theme)
            }
            
            // 编辑器
            PoemEditorView(
                title: $title,
                content: $content,
                placeholder: "围绕「\(selectedTheme ?? "")」展开创作...",
                showWordCount: !isKeyboardVisible
            )
            
            // AI 建议按钮（键盘弹起时隐藏）
            if !isKeyboardVisible {
                if !aiSuggestion.isEmpty {
                    suggestionSection
                } else if !isLoadingAI {
                    Button(action: getAISuggestion) {
                        HStack {
                            Image(systemName: "lightbulb")
                            Text("获取创作灵感")
                        }
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.accentTeal)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Colors.white)
                        .cornerRadius(CornerRadius.medium)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                } else {
                    HStack {
                        ProgressView()
                        Text("AI 正在生成创作建议...")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                    }
                    .padding(Spacing.md)
                }
            }
            
            // 底部按钮（键盘弹起时隐藏）
            if !isKeyboardVisible {
                bottomButtons
            }
        }
        .onAppear {
            // 监听键盘显示/隐藏
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    isKeyboardVisible = true
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    isKeyboardVisible = false
                }
            }
        }
    }
    
    private func themeHeader(theme: String) -> some View {
        HStack {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundColor(Colors.accentTeal)
                Text("主题：\(theme)")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.white)
    }
    
    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Colors.accentTeal)
                Text("创作建议")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    showingSuggestion.toggle()
                }) {
                    Image(systemName: showingSuggestion ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            if showingSuggestion {
                Text(aiSuggestion)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(4)
            }
        }
        .padding(Spacing.md)
        .background(Colors.accentTeal.opacity(0.05))
        .cornerRadius(CornerRadius.medium)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }
    
    private var bottomButtons: some View {
        Button(action: savePoem) {
            Text("保存")
                .font(Fonts.bodyRegular())
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.accentTeal)
                .cornerRadius(CornerRadius.medium)
        }
        .disabled(content.isEmpty)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Colors.backgroundCream)
        .sheet(isPresented: $showingShareSheet) {
            if let poem = currentPoem {
                ShareSheet(poem: poem)
            }
        }
    }
    
    // MARK: - Actions
    
    private func selectTheme(_ theme: String) {
        selectedTheme = theme
        getAISuggestion()
    }
    
    private func getAISuggestion() {
        guard let theme = selectedTheme else { return }
        
        isLoadingAI = true
        
        Task {
            do {
                let suggestion = try await AIService.shared.getWritingSuggestion(theme: theme)
                await MainActor.run {
                    aiSuggestion = suggestion
                    isLoadingAI = false
                    showingSuggestion = true
                }
            } catch {
                await MainActor.run {
                    aiSuggestion = "暂时无法获取建议，请稍后重试"
                    isLoadingAI = false
                    showingSuggestion = true
                }
            }
        }
    }
    
    private func savePoem() {
        guard selectedTheme != nil else { return }
        
        // 创建新诗歌并保存到诗集
        var poem = Poem(
            title: title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .theme,
            inMyCollection: true,  // 保存到诗集
            inSquare: false
        )
        currentPoem = poem
        poemManager.saveToCollection(poem)
        
        // 保存成功后，显示分享选项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingShareSheet = true
        }
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let theme: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(theme)
                .font(Fonts.titleLarge())
                .foregroundColor(Colors.textInk)
            
            Text(getThemeDescription(theme))
                .font(Fonts.footnote())
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func getThemeDescription(_ theme: String) -> String {
        switch theme {
        case "风": return "流动·变化"
        case "雨": return "洗涤·思念"
        case "窗": return "界限·眺望"
        case "梦": return "虚实·愿望"
        case "城市": return "现代·孤独"
        case "孤独": return "独处·内心"
        case "爱": return "情感·连接"
        case "时间": return "流逝·永恒"
        case "海": return "广阔·包容"
        case "夜晚": return "静谧·思考"
        default: return "意象·诗意"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ThemeWritingView()
    }
}


