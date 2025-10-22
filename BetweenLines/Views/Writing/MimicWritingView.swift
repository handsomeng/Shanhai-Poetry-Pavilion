//
//  MimicWritingView.swift
//  山海诗馆
//
//  模仿写诗模式：参考经典诗歌学习创作
//

import SwiftUI

struct MimicWritingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    
    // 参考诗歌列表
    let referencePoems = [
        ReferencePoem(title: "一代人", author: "顾城", content: "黑夜给了我黑色的眼睛\n我却用它寻找光明"),
        ReferencePoem(title: "远和近", author: "顾城", content: "你\n一会看我\n一会看云\n\n我觉得\n你看我时很远\n你看云时很近"),
        ReferencePoem(title: "断章", author: "卞之琳", content: "你站在桥上看风景\n看风景的人在楼上看你\n\n明月装饰了你的窗子\n你装饰了别人的梦"),
        ReferencePoem(title: "小巷", author: "北岛", content: "小巷\n又弯又长\n没有门\n没有窗\n我拿把旧钥匙\n敲着厚厚的墙")
    ]
    
    @State private var selectedReference: ReferencePoem?
    @State private var showingReferencePicker = true
    
    // 创作内容
    @State private var title = ""
    @State private var content = ""
    @State private var currentPoem: Poem?
    @State private var showingShareSheet = false
    @State private var isKeyboardVisible = false
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            if let reference = selectedReference {
                splitView(reference: reference)
            } else {
                referenceSelectionView
            }
        }
        .navigationTitle("模仿写诗")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            if selectedReference != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("换一首") {
                        selectedReference = nil
                        title = ""
                        content = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Reference Selection View
    
    private var referenceSelectionView: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("选择参考诗歌")
                    .font(Fonts.titleLarge())
                    .foregroundColor(Colors.textInk)
                
                Text("从经典诗歌中学习创作技巧")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
            
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(referencePoems) { poem in
                        Button(action: {
                            selectedReference = poem
                        }) {
                            ReferencePoemCard(poem: poem)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, Spacing.xl)
    }
    
    // MARK: - Split View
    
    private func splitView(reference: ReferencePoem) -> some View {
        VStack(spacing: 0) {
            // 上半部分：参考诗歌
            referenceSection(reference: reference)
            
            Divider()
                .background(Colors.divider)
            
            // 下半部分：创作区
            creationSection
            
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
    
    private func referenceSection(reference: ReferencePoem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reference.title)
                        .font(Fonts.titleMedium())
                        .foregroundColor(Colors.textInk)
                    
                    Text(reference.author)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "book.fill")
                    .foregroundColor(Colors.accentTeal.opacity(0.3))
                    .font(.system(size: 24))
            }
            
            ScrollView {
                Text(reference.content)
                    .font(Fonts.bodyPoem())
                    .foregroundColor(Colors.textInk)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Spacing.lg)
        .frame(maxHeight: .infinity)
        .background(Colors.white)
    }
    
    private var creationSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("你的创作")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textSecondary)
                
                Spacer()
                
                Image(systemName: "pencil.line")
                    .foregroundColor(Colors.accentTeal.opacity(0.3))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Colors.backgroundCream)
            
            PoemEditorView(
                title: $title,
                content: $content,
                placeholder: "参考上面的诗歌，写下你的创作...",
                showWordCount: !isKeyboardVisible
            )
        }
        .frame(maxHeight: .infinity)
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
    
    private func savePoem() {
        guard let reference = selectedReference else { return }
        
        // 创建新诗歌并保存到诗集
        let poem = Poem(
            title: title,
            content: content,
            authorName: poemManager.currentUserName,
            tags: [],
            writingMode: .mimic,
            referencePoem: "《\(reference.title)》- \(reference.author)",
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

// MARK: - Reference Poem Model

struct ReferencePoem: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let content: String
}

// MARK: - Reference Poem Card

private struct ReferencePoemCard: View {
    let poem: ReferencePoem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poem.title)
                        .font(Fonts.titleMedium())
                        .foregroundColor(Colors.textInk)
                    
                    Text(poem.author)
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
            }
            
            Text(poem.content)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .lineLimit(3)
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MimicWritingView()
    }
}


