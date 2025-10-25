//
//  SettingsView.swift
//  BetweenLines - 山海诗馆
//
//  设置页面
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var identityService = UserIdentityService()
    @AppStorage("penName") private var penName: String = ""
    @State private var showResetAlert = false
    @State private var showSuccessToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // 顶部留白（减少）
                        Spacer()
                            .frame(height: Spacing.sm)
                        
                        // 个人设置区域
                        settingsSection(title: "个人信息") {
                            settingRow(
                                label: "笔名",
                                value: $penName,
                                placeholder: "给自己起个富有诗意的名字"
                            )
                        }
                        
                        // 法律与政策
                        settingsSection(title: "法律与政策") {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                navigationRow(label: "隐私政策")
                            }
                            
                            Divider()
                                .padding(.horizontal, Spacing.md)
                            
                            NavigationLink(destination: TermsOfServiceView()) {
                                navigationRow(label: "用户协议")
                            }
                        }
                        
                        // 关于区域（直接显示内容）
                        settingsSection(title: "关于") {
                            VStack(spacing: 0) {
                                infoRow(label: "应用名称", value: "山海诗馆")
                                
                                Divider()
                                    .padding(.horizontal, Spacing.md)
                                
                                infoRow(label: "版本", value: "v1.0.0")
                                
                                Divider()
                                    .padding(.horizontal, Spacing.md)
                                
                                // 开发者（可点击）
                                Button(action: {
                                    if let url = URL(string: "https://www.handsomeng.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text("开发者")
                                            .font(Fonts.bodyRegular())
                                            .foregroundColor(Colors.textSecondary)
                                        Spacer()
                                        Text("HandsomeMeng")
                                            .font(Fonts.bodyRegular())
                                            .foregroundColor(Colors.accentTeal)
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(Colors.accentTeal)
                                    }
                                    .padding(.vertical, Spacing.md)
                                    .padding(.horizontal, Spacing.md)
                                }
                                
                                Divider()
                                    .padding(.horizontal, Spacing.md)
                                
                                // 特别感谢
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    Text("特别感谢")
                                        .font(Fonts.bodyRegular())
                                        .foregroundColor(Colors.textSecondary)
                                    
                                    Text("Cursor、Claude、DeepSeek 和所有山海诗馆的诗人们")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(Colors.textInk)
                                        .lineSpacing(4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, Spacing.md)
                                .padding(.horizontal, Spacing.md)
                            }
                        }
                        
                        // 数据管理区域
                        settingsSection(title: "数据管理") {
                            // 重置本地数据
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
                        
                        // 底部留白（减少）
                        Spacer()
                            .frame(height: Spacing.lg)
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
                Text("此操作将删除所有诗歌、草稿、个人信息和云端数据，且不可恢复。确定要继续吗？")
            }
        }
    }
    
    // MARK: - 设置区域组件
    
    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Colors.textSecondary)
                .tracking(3)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Colors.white)
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Colors.border.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
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
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Colors.textSecondary)
            
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
    
    // MARK: - 导航行
    
    @ViewBuilder
    private func navigationRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(Fonts.bodyRegular())
                .foregroundColor(Colors.textInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Colors.textTertiary)
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.md)
        .contentShape(Rectangle())
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
        // 1. 清除本地所有诗歌数据
        PoemManager.shared.deleteAll()
        
        // 2. 清空笔名
        penName = ""
        identityService.setPenName("")
        
        // 3. 清除所有 UserDefaults 数据
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // 4. 清除 iCloud 数据
        let iCloudStore = NSUbiquitousKeyValueStore.default
        iCloudStore.dictionaryRepresentation.keys.forEach { key in
            iCloudStore.removeObject(forKey: key)
        }
        iCloudStore.synchronize()
        
        ToastManager.shared.showSuccess("所有数据已重置")
        
        // 关闭设置页
        dismiss()
    }
}

#Preview {
    SettingsView()
}

