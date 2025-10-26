//
//  WarmJapaneseTemplate.swift
//  山海诗馆
//
//  暖系日系模板：温暖治愈，日系美学
//

import SwiftUI

struct WarmJapaneseTemplate: PoemTemplateRenderable {
    var id = "warm_japanese"
    var name = "暖系日系"
    var icon = "🌸"
    
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部留白
            Spacer()
                .frame(height: 24)
            
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "8B7355"))
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
            }
            
            // 正文
            Text(poem.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "6B5D4F"))
                .lineSpacing(11)
                .tracking(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
                .frame(height: 32)
            
            // 统一底部信息
            PoemBottomInfo(
                poem: poem,
                poemIndex: poemIndex,
                textColor: Color(hex: "8B7355"),
                dividerColor: Color(hex: "E8DCC8")
            )
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .frame(width: size.width)
        .background(Color(hex: "FFF8F0"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
                .foregroundColor(Color(hex: "E8DCC8"))
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 2)
    }
}

