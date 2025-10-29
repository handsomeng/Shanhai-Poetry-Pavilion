//
//  MountainSeaTemplate.swift
//  山海诗馆
//
//  山海国风模板：中国传统美学，水墨意境
//

import SwiftUI

struct MountainSeaTemplate: PoemTemplateRenderable {
    var id = "mountain_sea"
    var name = "山海国风"
    var icon = "🎨"
    
    @ViewBuilder
    func render(poem: Poem, poemIndex: Int, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部留白
            Spacer()
                .frame(height: 24)
            
            // 标题（带书名号）
            Text(poem.displayTitle)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "2C2C2C"))
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
            
            // 正文
            Text(poem.content)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "4A3C2A"))
                .lineSpacing(12)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
                .frame(height: 32)
            
            // 统一底部信息
            PoemBottomInfo(
                poem: poem,
                poemIndex: poemIndex,
                textColor: Color(hex: "8B7355"),
                dividerColor: Color(hex: "C8B8A0")
            )
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 44)
        .frame(width: size.width)
        .background(
            LinearGradient(
                colors: [Color(hex: "F5F0E8"), Color(hex: "EDE8DC")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 2)
    }
}

