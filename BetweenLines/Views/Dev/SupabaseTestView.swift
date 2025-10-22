//
//  SupabaseTestView.swift
//  山海诗馆
//
//  Supabase 连接测试视图（仅用于开发）
//

import SwiftUI

struct SupabaseTestView: View {
    
    @State private var isConfigured = false
    @State private var isConnected = false
    @State private var isTesting = false
    @State private var testResult = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // 配置检查
                        configSection
                        
                        // 连接测试
                        connectionSection
                        
                        // 测试结果
                        if !testResult.isEmpty {
                            resultSection
                        }
                        
                        // 快速指南
                        guideSection
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("后端连接测试")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkConfiguration()
            }
        }
    }
    
    // MARK: - Config Section
    
    private var configSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("配置检查")
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
            
            HStack(spacing: Spacing.md) {
                Image(systemName: isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isConfigured ? .green : .red)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isConfigured ? "配置正确" : "配置未完成")
                        .font(Fonts.bodyLarge())
                        .foregroundColor(Colors.textInk)
                    
                    if !isConfigured {
                        Text("请在 SupabaseClient.swift 中填入 API 密钥")
                            .font(Fonts.caption())
                            .foregroundColor(Colors.textSecondary)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
        }
    }
    
    // MARK: - Connection Section
    
    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("连接测试")
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
            
            Button(action: testConnection) {
                HStack {
                    if isTesting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    Text(isTesting ? "测试中..." : "测试连接")
                        .font(Fonts.bodyRegular())
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Colors.accentTeal)
                .foregroundColor(.white)
                .cornerRadius(CornerRadius.medium)
            }
            .disabled(isTesting || !isConfigured)
            .opacity(isConfigured ? 1.0 : 0.5)
        }
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("测试结果")
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
            
            Text(testResult)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Colors.white)
                .cornerRadius(CornerRadius.card)
        }
    }
    
    // MARK: - Guide Section
    
    private var guideSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("快速指南")
                .font(Fonts.titleMedium())
                .foregroundColor(Colors.textInk)
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                GuideStep(number: 1, text: "访问 supabase.com 创建项目")
                GuideStep(number: 2, text: "在 SQL Editor 执行 supabase_schema.sql")
                GuideStep(number: 3, text: "在 Settings → API 复制 URL 和 anon key")
                GuideStep(number: 4, text: "粘贴到 SupabaseClient.swift 文件")
                GuideStep(number: 5, text: "回到这里测试连接")
            }
            .padding(Spacing.lg)
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
        }
    }
    
    // MARK: - Actions
    
    private func checkConfiguration() {
        isConfigured = SupabaseConfig.validate()
    }
    
    private func testConnection() {
        isTesting = true
        testResult = ""
        
        Task {
            do {
                // 测试查询 profiles 表
                let _: [UserProfile] = try await supabase.database
                    .from("profiles")
                    .select()
                    .limit(1)
                    .execute()
                    .value
                
                await MainActor.run {
                    testResult = "✅ 连接成功！\n数据库表正常访问。"
                    isConnected = true
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "❌ 连接失败\n\(error.localizedDescription)\n\n请检查：\n1. API 密钥是否正确\n2. SQL 脚本是否已执行\n3. 网络连接是否正常"
                    isConnected = false
                    isTesting = false
                }
            }
        }
    }
}

// MARK: - Guide Step

private struct GuideStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text("\(number)")
                .font(Fonts.bodyRegular())
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Colors.accentTeal)
                .clipShape(Circle())
            
            Text(text)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    SupabaseTestView()
}

