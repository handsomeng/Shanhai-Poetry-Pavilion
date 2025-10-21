//
//  SettingsView.swift
//  BetweenLines - 山海诗馆
//
//  设置页面
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("penName") private var penName: String = ""
    @State private var showResetAlert = false
    @State private var showSuccessToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        // 顶部留白
                        Spacer()
                            .frame(height: Spacing.lg)
                        
                        // 个人设置区域
                        settingsSection(title: "个人信息") {
                            settingRow(
                                label: "笔名",
                                value: $penName,
                                placeholder: "给自己起个富有诗意的名字"
                            )
                        }
                        
                        // 关于区域
                        settingsSection(title: "关于应用") {
                            infoRow(label: "应用名称", value: AppConstants.appName)
                            infoRow(label: "版本号", value: "v\(AppConstants.version)")
                            infoRow(label: "开发者", value: "HandsoMeng")
                        }
                        
                        // 危险操作区域
                        settingsSection(title: "数据管理") {
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Text("重置所有数据")
                                        .font(Fonts.bodyRegular())
                                        .foregroundColor(Colors.error)
                                    Spacer()
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .ultraLight))
                                        .foregroundColor(Colors.error)
                                }
                                .padding(.vertical, Spacing.md)
                                .padding(.horizontal, Spacing.md)
                            }
                        }
                        
                        Spacer()
                            .frame(height: Spacing.xxl)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                
                // 成功提示
                if showSuccessToast {
                    VStack {
                        Spacer()
                        Text("保存成功")
                            .font(Fonts.bodyRegular())
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                            .background(Colors.accentTeal)
                            .cornerRadius(CornerRadius.medium)
                            .padding(.bottom, Spacing.xxl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)  // 改为 inline，更简洁
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        saveSettings()
                        dismiss()
                    }
                    .font(Fonts.bodyLight())
                    .foregroundColor(Colors.textInk)
                }
            }
            .alert("重置所有数据", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认重置", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("此操作将删除所有诗歌、草稿和个人信息，且不可恢复。确定要继续吗？")
            }
        }
    }
    
    // MARK: - 设置区域组件
    
    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(title.uppercased())
                .font(Fonts.footnote())
                .foregroundColor(Colors.textTertiary)  // 改为更清晰的颜色
                .tracking(3)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Colors.white)
            .overlay(
                Rectangle()
                    .stroke(Colors.border, lineWidth: 0.3)
            )
        }
    }
    
    // MARK: - 可编辑行
    
    @ViewBuilder
    private func settingRow(
        label: String,
        value: Binding<String>,
        placeholder: String,
        isSecure: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(Fonts.caption())
                .foregroundColor(Colors.textSecondary)  // 改为更清晰的颜色
            
            if isSecure {
                SecureField(placeholder, text: value)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                    .textFieldStyle(.plain)
            } else {
                TextField(placeholder, text: value)
                    .font(Fonts.bodyRegular())
                    .foregroundColor(Colors.textInk)
                    .textFieldStyle(.plain)
            }
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.md)
    }
    
    // MARK: - 只读信息行
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.md)
    }
    
    // MARK: - 保存设置
    
    private func saveSettings() {
        // 所有设置都通过 @AppStorage 自动保存
        // 这里可以添加额外的验证逻辑
        
        showSuccessToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSuccessToast = false
        }
    }
    
    // MARK: - 重置数据
    
    private func resetAllData() {
        // 清除所有 UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // 重置 PoemManager
        PoemManager.shared.deleteAll()
        
        // 关闭设置页
        dismiss()
        
        // 注意：这会导致应用返回引导页，因为 hasCompletedOnboarding 被清除
    }
}

#Preview {
    SettingsView()
}

