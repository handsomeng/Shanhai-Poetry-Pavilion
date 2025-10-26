//
//  HandwrittenTemplate.swift
//  山海诗馆
//
//  手写笔记模板：手写温度，真实感
//

import SwiftUI

struct HandwrittenTemplate: PoemTemplateRenderable {
    var id = "handwritten"
    var name = "手写笔记"
    var icon = "✍️"
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 左侧红线（活页纸样式）
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "E63946"))
                    .frame(width: 2)
                
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部日期
                    HStack {
                        Text(poem.createdAt, style: .date)
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(Color(hex: "6B88A1"))
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    // 标题（如果有）
                    if !poem.title.isEmpty {
                        Text(poem.title)
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(Color(hex: "1A4D8F"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                    }
                    
                    // 正文（带横线背景）
                    ZStack(alignment: .topLeading) {
                        // 横线背景
                        VStack(spacing: 24) {
                            ForEach(0..<15, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(hex: "B8D4E8"))
                                    .frame(height: 1)
                            }
                        }
                        
                        // 正文内容
                        Text(poem.content)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(Color(hex: "1A4D8F"))
                            .lineSpacing(22)
                            .tracking(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                        .frame(height: 32)
                    
                    // 底部：手写签名效果
                    HStack {
                        Spacer()
                        Text("—— \(poem.authorName)")
                            .font(.system(size: 13, weight: .light, design: .serif))
                            .foregroundColor(Color(hex: "4A7198"))
                            .italic()
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 28)
                .padding(.vertical, 36)
            }
        }
        .frame(width: size.width)
        .background(Color(hex: "FFFEF7"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 2)
        .rotationEffect(.degrees(0.5)) // 轻微倾斜，增加手写感
    }
}

