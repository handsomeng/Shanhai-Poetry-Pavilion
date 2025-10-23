//
//  ExploreView.swift
//  山海诗馆
//
//  赏诗主视图：广场建设中
//

import SwiftUI

struct ExploreView: View {
    
    // 统计用户反馈
    @AppStorage("wantSquareFeature") private var wantSquareFeature = false
    @State private var showThanksAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // 图标
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(Colors.textInk)
                        .scaleEffect(showThanksAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showThanksAnimation)
                    
                    VStack(spacing: 16) {
                        // 标题
                        Text("诗歌广场")
                            .font(Fonts.h1())
                            .foregroundColor(Colors.textInk)
                        
                        // 副标题
                        Text("建设中...")
                            .font(Fonts.h2Small())
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    // 说明文字
                    VStack(spacing: 12) {
                        Text("诗歌广场正在精心筹备中")
                            .font(Fonts.body())
                            .foregroundColor(Colors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            featureRow(icon: "doc.text", text: "分享你的诗歌作品")
                            featureRow(icon: "heart", text: "欣赏他人的创作")
                            featureRow(icon: "bubble.left.and.bubble.right", text: "与诗友交流互动")
                            featureRow(icon: "star", text: "发现优秀诗歌")
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 我想要按钮
                    if !wantSquareFeature {
                        Button(action: {
                            wantSquareFeature = true
                            showThanksAnimation = true
                            ToastManager.shared.showSuccess("感谢反馈！我们会加快开发进度 ✨")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showThanksAnimation = false
                            }
                            
                            // TODO: 可以在这里记录到后端
                            print("📊 用户想要广场功能")
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 18))
                                Text("我想要这个功能")
                                    .font(Fonts.body())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Colors.textInk)
                            .cornerRadius(16)
                            .shadow(color: Colors.textInk.opacity(0.3), radius: 8, y: 4)
                        }
                        .padding(.horizontal, 32)
                    } else {
                        // 已反馈
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Colors.textInk)
                            Text("感谢您的反馈")
                                .font(Fonts.body())
                                .foregroundColor(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Colors.textSecondary.opacity(0.3), lineWidth: 2)
                        )
                        .padding(.horizontal, 32)
                    }
                    
                    // 提示文字
                    Text("暂时您可以通过分享功能\n将诗歌分享给朋友")
                        .font(Fonts.caption())
                        .foregroundColor(Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("赏诗")
                        .font(Fonts.h2Small())
                        .foregroundColor(Colors.textInk)
                }
            }
        }
        .withToast()
    }
    
    // MARK: - 功能行
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Colors.textInk)
                .frame(width: 20)
            
            Text(text)
                .font(Fonts.body())
                .foregroundColor(Colors.textSecondary)
            
            Spacer()
        }
    }
}

#Preview {
    ExploreView()
}
