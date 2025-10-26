//
//  DarkNightTemplate.swift
//  山海诗馆
//
//  深夜暗黑模板：深邃神秘，夜间阅读友好
//

import SwiftUI

struct DarkNightTemplate: PoemTemplate {
    var id = "dark_night"
    var name = "深夜暗黑"
    var icon = "🌙"
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部：日期（左）和 logo（右）
            HStack {
                Text(poem.createdAt, style: .date)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "6C6C70"))
                
                Spacer()
                
                Text("山海诗馆")
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "48484A"))
                    .tracking(1)
            }
            .padding(.bottom, 24)
            
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 20, weight: .thin, design: .serif))
                    .foregroundColor(Color(hex: "E5E5EA"))
                    .tracking(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
            }
            
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
            
            // 底部标识：作者名
            HStack(spacing: 0) {
                Spacer()
                Text("—— \(poem.authorName)")
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .foregroundColor(Color(hex: "6C6C70"))
            }
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

