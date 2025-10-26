//
//  CyberpunkTemplate.swift
//  山海诗馆
//
//  赛博朋克模板：未来科技，霓虹美学
//

import SwiftUI

struct CyberpunkTemplate: PoemTemplateRenderable {
    var id = "cyberpunk"
    var name = "赛博朋克"
    var icon = "🌃"
    
    @ViewBuilder
    func render(poem: Poem, size: CGSize) -> some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 扫描线效果
            VStack(spacing: 5) {
                ForEach(0..<20, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .frame(height: 1)
                }
            }
            
            // 主内容
            VStack(alignment: .leading, spacing: 0) {
                // 顶部：日期 + 时间
                HStack {
                    Text(poem.createdAt, format: .dateTime.year().month().day())
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "0FF4C6"))
                    
                    Spacer()
                    
                    Text("BETWEENLINES")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "0FF4C6").opacity(0.6))
                        .tracking(2)
                }
                .padding(.bottom, 24)
                
                // 边角装饰
                HStack {
                    VStack {
                        Rectangle()
                            .fill(Color(hex: "0FF4C6"))
                            .frame(width: 2, height: 16)
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        Rectangle()
                            .fill(Color(hex: "0FF4C6"))
                            .frame(width: 2, height: 16)
                        Spacer()
                    }
                }
                .frame(height: 20)
                .padding(.bottom, 16)
                
                // 标题（如果有）
                if !poem.title.isEmpty {
                    Text(poem.title)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "0FF4C6"))
                        .tracking(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 16)
                }
                
                // 正文
                Text(poem.content)
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .lineSpacing(10)
                    .tracking(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                    .frame(height: 28)
                
                // 底部：作者名
                HStack {
                    Text("> \(poem.authorName)")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(hex: "0FF4C6"))
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
        .frame(width: size.width)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "0FF4C6"), lineWidth: 2)
        )
        .shadow(color: Color(hex: "0FF4C6").opacity(0.3), radius: 16, x: 0, y: 4)
    }
}

