//
//  AboutDeveloperView.swift
//  BetweenLines - 山海诗馆
//
//  关于开发者页面
//

import SwiftUI

struct AboutDeveloperView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // 开发者图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Colors.accentTeal.opacity(0.2),
                                        Colors.accentTeal.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Text("🧑‍💻")
                            .font(.system(size: 60))
                    }
                    
                    VStack(spacing: 12) {
                        // 开发者名字
                        Text("HandsoMeng")
                            .font(.system(size: 28, weight: .medium, design: .serif))
                            .foregroundColor(Colors.textInk)
                        
                        Text("独立开发者")
                            .font(.system(size: 15))
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    // 主页按钮
                    Button(action: {
                        if let url = URL(string: "https://www.handsomeng.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .font(.system(size: 16, weight: .medium))
                            Text("访问主页")
                                .font(.system(size: 17, weight: .medium))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Colors.accentTeal)
                        .cornerRadius(25)
                        .shadow(color: Colors.accentTeal.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    // 版权信息
                    Text("© 2025 HandsoMeng")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.textTertiary)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("关于 HandsoMeng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    AboutDeveloperView()
}

