//
//  PoetTitleView.swift
//  山海诗馆
//
//  诗人称号系统详情页
//

import SwiftUI

struct PoetTitleView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var poemManager = PoemManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // 当前称号卡片
                        currentTitleCard
                        
                        // 进度条（如果不是最高称号）
                        if !poemManager.currentPoetTitle.isMaxTitle {
                            progressSection
                        }
                        
                        // 所有称号列表
                        allTitlesSection
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xl)
                }
            }
            .navigationTitle("诗人称号")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Current Title Card
    
    private var currentTitleCard: some View {
        VStack(spacing: Spacing.lg) {
            // 称号图标
            Text(poemManager.currentPoetTitle.icon)
                .font(.system(size: 64))
            
            // 称号名称
            Text(poemManager.currentPoetTitle.displayName)
                .font(Fonts.h2())
                .foregroundColor(Colors.textInk)
            
            // 称号描述
            Text(poemManager.currentPoetTitle.description)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            // 统计
            HStack(spacing: Spacing.lg) {
                StatBadge(
                    value: "\(poemManager.myCollection.count)",
                    label: "已写诗歌"
                )
                
                if let next = poemManager.poemsToNextTitle {
                    StatBadge(
                        value: "\(next)",
                        label: "距下一称号"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("升级进度")
                    .font(Fonts.h2Small())
                    .foregroundColor(Colors.textInk)
                
                Spacer()
                
                Text("\(Int(poemManager.progressToNextTitle * 100))%")
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.accentTeal)
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Colors.backgroundCream)
                        .frame(height: 8)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Colors.accentTeal, Colors.accentTeal.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * poemManager.progressToNextTitle,
                            height: 8
                        )
                }
            }
            .frame(height: 8)
            
            if let next = poemManager.poemsToNextTitle,
               let nextTitle = poemManager.currentPoetTitle.nextTitleRequiredCount {
                let nextTitleName = PoetTitle.title(forPoemCount: nextTitle).displayName
                Text("再写 \(next) 首即可解锁「\(nextTitleName)」")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - All Titles Section
    
    private var allTitlesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("全部称号")
                .font(Fonts.h2Small())
                .foregroundColor(Colors.textInk)
                .padding(.horizontal, Spacing.sm)
            
            VStack(spacing: Spacing.sm) {
                ForEach(poemManager.titleAchievements, id: \.title) { achievement in
                    TitleRow(achievement: achievement)
                }
            }
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Fonts.h2())
                .foregroundColor(Colors.accentTeal)
            
            Text(label)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
        }
    }
}

// MARK: - Title Row

private struct TitleRow: View {
    let achievement: TitleAchievement
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 图标
            Text(achievement.title.icon)
                .font(.system(size: 32))
                .frame(width: 48)
                .opacity(achievement.isUnlocked ? 1.0 : 0.3)
            
            // 称号信息
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title.displayName)
                    .font(Fonts.bodyLarge())
                    .foregroundColor(achievement.isUnlocked ? Colors.textInk : Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(achievement.title.description)
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // 状态
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Colors.accentTeal)
                    
                    Text("已解锁")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.accentTeal)
                }
            } else {
                Text("需 \(achievement.title.requiredCount) 首")
                    .font(Fonts.caption())
                    .foregroundColor(Colors.textSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Colors.backgroundCream)
                    .cornerRadius(CornerRadius.small)
            }
        }
        .padding(Spacing.md)
        .background(Colors.white)
        .cornerRadius(CornerRadius.card)
        .shadow(color: .black.opacity(achievement.isUnlocked ? 0.05 : 0.02), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    PoetTitleView()
}

