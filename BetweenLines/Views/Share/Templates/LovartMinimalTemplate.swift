//
//  LovartMinimalTemplate.swift
//  山海诗馆
//
//  Lovart 极简模板：黑白简约风格
//

import SwiftUI

struct LovartMinimalTemplate: PoemTemplateRenderable {
    var id = "lovart_minimal"
    var name = "Lovart 极简"
    var icon = "🤍"
    
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部留白
            Spacer()
                .frame(height: 24)
            
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "0A0A0A"))
                    .tracking(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
            }
            
            // 正文
            Text(poem.content)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "333333"))
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
                textColor: Color(hex: "666666"),
                dividerColor: Color(hex: "E5E5E5")
            )
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .frame(width: size.width)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 2)
    }
}

