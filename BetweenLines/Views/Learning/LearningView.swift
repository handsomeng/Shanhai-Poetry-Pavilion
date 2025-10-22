//
//  LearningView.swift
//  BetweenLines - 字里行间
//
//  学诗视图:浏览大主题 → 小主题 → 学习内容
//

import SwiftUI

/// 学诗主视图（显示所有大主题）
struct LearningView: View {
    
    // MARK: - 状态
    
    /// 所有大主题
    @State private var topics: [LearningTopic] = LearningContentManager.shared.getAllTopics()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // 顶部标题
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("学诗")
                                .font(Fonts.titleLarge())
                                .foregroundColor(Colors.textInk)
                            
                            Text("从零开始，了解现代诗的创作技巧与美学")
                                .font(Fonts.caption())
                                .foregroundColor(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        
                        // 大主题卡片列表
                        ForEach(topics) { topic in
                            NavigationLink(destination: TopicDetailView(topic: topic)) {
                                TopicCardView(topic: topic)
                                    .padding(.horizontal, Spacing.lg)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                            .frame(height: Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 大主题卡片

/// 大主题卡片（在主列表显示）
private struct TopicCardView: View {
    
    let topic: LearningTopic
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 图标
            ZStack {
                Circle()
                    .fill(Colors.accentTeal.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: topic.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Colors.accentTeal)
            }
            
            // 主题信息
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(topic.title)
                    .font(Fonts.titleMedium())
                    .foregroundColor(Colors.textInk)
                
                Text(topic.description)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                    .lineLimit(2)
                
                // 元信息
                HStack(spacing: Spacing.md) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 12))
                        Text("\(topic.articleCount) 篇")
                            .font(Fonts.footnote())
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("\(topic.totalReadingTime) 分钟")
                            .font(Fonts.footnote())
                    }
                }
                .foregroundColor(Colors.textSecondary)
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

// MARK: - 大主题详情视图

/// 大主题详情页（显示该主题下的所有文章）
struct TopicDetailView: View {
    
    let topic: LearningTopic
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // 主题介绍
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: topic.icon)
                                .font(.system(size: 32))
                                .foregroundColor(Colors.accentTeal)
                            
                            Spacer()
                        }
                        
                        Text(topic.description)
                            .font(Fonts.bodyRegular())
                            .foregroundColor(Colors.textSecondary)
                        
                        HStack(spacing: Spacing.md) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                Text("\(topic.articleCount) 篇文章")
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("约 \(topic.totalReadingTime) 分钟")
                            }
                        }
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    
                    Divider()
                        .padding(.horizontal, Spacing.lg)
                    
                    // 文章列表
                    Text("文章列表")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textSecondary)
                        .padding(.horizontal, Spacing.lg)
                    
                    ForEach(topic.articles.sorted(by: { $0.order < $1.order })) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleListItemView(article: article)
                                .padding(.horizontal, Spacing.lg)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                        .frame(height: Spacing.xl)
                }
            }
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 文章列表项

/// 文章列表项（在主题详情页显示）
private struct ArticleListItemView: View {
    
    let article: LearningArticle
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 序号
            ZStack {
                Circle()
                    .fill(Colors.backgroundCream)
                    .frame(width: 32, height: 32)
                
                Text("\(article.order)")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.accentTeal)
                    .fontWeight(.medium)
            }
            
            // 文章信息
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(article.title)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                
                Text(article.summary)
                    .font(Fonts.footnote())
                    .foregroundColor(Colors.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(article.readingTimeMinutes) 分钟")
                        .font(Fonts.footnote())
                }
                .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Colors.textSecondary)
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - 文章详情视图

/// 文章详情页（显示完整学习内容）
struct ArticleDetailView: View {
    
    let article: LearningArticle
    
    // MARK: - 环境对象
    
    @EnvironmentObject var tabManager: TabManager
    
    // MARK: - 状态
    
    /// 是否显示"一键开始临摹"提示
    @State private var showMimicPrompt = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Colors.backgroundCream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // 文章元信息
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack(spacing: Spacing.md) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("\(article.readingTimeMinutes) 分钟")
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "number")
                                Text("第 \(article.order) 篇")
                            }
                        }
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)
                    
                    Divider()
                        .padding(.horizontal, Spacing.lg)
                    
                    // Markdown 内容（简化版：直接显示文本）
                    // 实际项目中可以使用 MarkdownUI 库渲染
                    Text(article.content)
                        .font(Fonts.bodyRegular())
                        .foregroundColor(Colors.textInk)
                        .padding(.horizontal, Spacing.lg)
                    
                    // 免责声明
                    Text("此模块内容为 AI 生成，如有问题联系开发者修改")
                        .font(Fonts.footnote())
                        .foregroundColor(Colors.textSecondary.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)
                    
                    // 底部操作按钮
                    VStack(spacing: Spacing.md) {
                        Divider()
                            .padding(.horizontal, Spacing.lg)
                        
                        Button(action: {
                            showMimicPrompt = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                Text("一键开始创作")
                            }
                            .font(Fonts.bodyRegular())
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Colors.accentTeal)
                            .foregroundColor(.white)
                            .cornerRadius(CornerRadius.medium)
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    Spacer()
                        .frame(height: Spacing.xl)
                }
            }
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("开始创作", isPresented: $showMimicPrompt) {
            Button("取消", role: .cancel) {}
            Button("前往写诗") {
                // 切换到写诗 Tab
                tabManager.switchTo(.writing)
            }
        } message: {
            Text("将跳转到【写诗】模块，开始你的第一首诗。")
        }
    }
}

// MARK: - 预览

#Preview("学诗主页") {
    LearningView()
}

#Preview("主题详情") {
    NavigationStack {
        TopicDetailView(topic: LearningContentManager.shared.getAllTopics().first!)
    }
}

#Preview("文章详情") {
    NavigationStack {
        ArticleDetailView(
            article: LearningContentManager.shared.getAllTopics().first!.articles.first!
        )
    }
}

