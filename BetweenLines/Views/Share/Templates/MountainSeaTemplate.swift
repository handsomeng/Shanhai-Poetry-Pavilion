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
    func render(poem: Poem, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部云纹装饰
            HStack {
                Text("〜")
                    .font(.system(size: 16, weight: .ultraLight))
                    .foregroundColor(Color(hex: "C8B8A0"))
                Spacer()
                Text("〜")
                    .font(.system(size: 16, weight: .ultraLight))
                    .foregroundColor(Color(hex: "C8B8A0"))
            }
            .padding(.bottom, 20)
            
            // 标题（如果有）
            if !poem.title.isEmpty {
                Text(poem.title)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "2C2C2C"))
                    .tracking(2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 24)
            }
            
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
            
            // 底部：竖排作者名 + 日期
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    Text(poem.authorName)
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundColor(Color(hex: "8B7355"))
                    
                    Text(poem.createdAt, style: .date)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(Color(hex: "A89B88"))
                    
                    // 印章装饰
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "CC3333"))
                            .frame(width: 32, height: 32)
                        
                        Text("山海")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    }
                    .rotationEffect(.degrees(5))
                }
            }
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

