//
//  DarkNightTemplate.swift
//  山海诗馆
//
//  深夜暗黑模板：深邃神秘，夜间阅读友好
//

import SwiftUI

struct DarkNightTemplate: PoemTemplateRenderable {
    var id = "dark_night"
    var name = "深夜暗黑"
    var icon = "🌙"
    
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部留白
            Spacer()
                .frame(height: 24)
            
            // 标题（带书名号）
            Text(poem.displayTitle)
                .font(.system(size: 20, weight: .thin, design: .serif))
                .foregroundColor(Color(hex: "E5E5EA"))
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
            
            // 正文
            Text(poem.content)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "C7C7CC"))
                .lineSpacing(10)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
                .frame(height: 32)
            
            // 统一底部信息
            PoemBottomInfo(
                poem: poem,
                poemIndex: poemIndex,
                textColor: Color(hex: "8E8E93"),
                dividerColor: Color(hex: "3A3A3C")
            )
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .frame(width: size.width)
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "3A3A3C"), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 4)
    }
}

