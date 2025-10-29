//
//  SettingsView.swift
//  BetweenLines - 山海诗馆
//
//  设置页面
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var identityService = UserIdentityService()
    @StateObject private var poemManager = PoemManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var toastManager = ToastManager.shared
    
    // 状态
    @State private var showingEditName = false
    @State private var showingPoetTitle = false
    @State private var showingMembershipDetail = false
    @State private var showingSubscription = false
    @State private var showingAboutApp = false
    @State private var showingAboutDeveloper = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 22) {
                        // 1. 个人信息区
                        personalInfoSection
                        
                        // 2. 会员状态卡片
                        membershipCard
                        
                        // 3. 设置列表
                        settingsList
                        
                        // 4. 底部版本信息
                        versionInfo
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 26)
                    .padding(.bottom, 44)
                }
            }
            .navigationTitle("设置")
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
        .sheet(isPresented: $showingEditName) {
            EditPenNameView(currentName: identityService.penName) { newName in
                identityService.setPenName(newName)
                toastManager.showSuccess("已保存")
            }
        }
        .sheet(isPresented: $showingPoetTitle) {
            PoetTitleView(poemCount: poemManager.allPoems.count)
        }
        .sheet(isPresented: $showingMembershipDetail) {
            if subscriptionManager.isSubscribed {
                MembershipDetailView()
            } else {
                SubscriptionView()
            }
        }
        .sheet(isPresented: $showingAboutDeveloper) {
            AboutDeveloperView()
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
    
    // MARK: - 个人信息区
    
    private var personalInfoSection: some View {
        HStack {
            // 笔名（可点击编辑）
            Button(action: { showingEditName = true }) {
                HStack(spacing: 4) {
                    Text(identityService.penName.isEmpty ? "山海诗人" : identityService.penName)
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(Colors.textInk)
                    
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Colors.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(showingEditName ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: showingEditName)
            
            // 称号标签（纯展示）
            Text(currentPoetTitle.displayName)
                .font(.system(size: 12))
                .foregroundColor(Colors.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Colors.textSecondary.opacity(0.08))
                .cornerRadius(5)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Colors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 会员状态卡片
    
    private var membershipCard: some View {
        Button(action: {
            showingMembershipDetail = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if subscriptionManager.isSubscribed {
                        // 已订阅状态
                        HStack(spacing: 4) {
                            Text("👑")
                            Text("山海已在你心间")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Colors.textInk)
                        }
                        
                        if let expiration = subscriptionManager.expirationDate {
                            Text("\(subscriptionType) · 到期 \(formattedDate(expiration))")
                                .font(.system(size: 13))
                                .foregroundColor(Colors.textSecondary)
                        } else {
                            Text(subscriptionType)
                                .font(.system(size: 13))
                                .foregroundColor(Colors.textSecondary)
                        }
                    } else {
                        // 未订阅状态
                        HStack(spacing: 4) {
                            Text("👑")
                            Text("升级会员")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Colors.textInk)
                        }
                        
                        Text("山海在眼前 · 免费试用7天")
                            .font(.system(size: 13))
                            .foregroundColor(Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if subscriptionManager.isSubscribed {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Colors.textTertiary)
                } else {
                    Text("立即订阅")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.accentTeal)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.accentTeal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.85),
                        Color(red: 1.0, green: 0.98, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 设置列表
    
    private var settingsList: some View {
        VStack(spacing: 16) {
            // 分组1: 账号与内容
            VStack(spacing: 0) {
                // 诗人等级
                Button(action: { showingPoetTitle = true }) {
                    settingRow(label: "诗人等级", showArrow: true)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 恢复购买
                Button(action: { restorePurchases() }) {
                    settingRow(label: "恢复购买", showArrow: true)
                }
            }
            .background(Colors.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            // 分组2: 关于
            VStack(spacing: 0) {
                // 关于山海诗馆
                NavigationLink(destination: AboutAppView()) {
                    settingRow(label: "关于山海诗馆", showArrow: true)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 关于 HandsoMeng
                Button(action: { showingAboutDeveloper = true }) {
                    settingRow(label: "关于 HandsoMeng", showArrow: true)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 用户协议
                NavigationLink(destination: TermsOfServiceView()) {
                    settingRow(label: "用户协议", showArrow: true)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 隐私政策
                NavigationLink(destination: PrivacyPolicyView()) {
                    settingRow(label: "隐私政策", showArrow: true)
                }
                .buttonStyle(.plain)
            }
            .background(Colors.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            // 分组3: 危险区域
            VStack(spacing: 0) {
                // 重置所有数据
                Button(action: { showResetAlert = true }) {
                    HStack {
                        Text("重置所有数据")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                }
            }
            .background(Colors.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - 设置行
    
    @ViewBuilder
    private func settingRow(label: String, showArrow: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Colors.textInk)
            Spacer()
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Colors.textTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
    
    // MARK: - 底部版本信息
    
    private var versionInfo: some View {
        Text("版本 1.0.0")
            .font(.system(size: 13))
            .foregroundColor(Colors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
    }
    
    // MARK: - 辅助方法
    
    /// 当前诗人等级
    private var currentPoetTitle: PoetTitle {
        let count = poemManager.allPoems.count
        return PoetTitle.title(forPoemCount: count)
    }
    
    /// 订阅类型文本
    private var subscriptionType: String {
        guard let type = subscriptionManager.currentSubscription else {
            return "未订阅"
        }
        switch type {
        case .monthly: return "月度订阅"
        case .quarterly: return "季度订阅"
        case .yearly: return "年度订阅"
        }
    }
    
    /// 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// 恢复购买
    private func restorePurchases() {
        toastManager.showInfo("正在恢复购买...")
        Task {
            // StoreKit 2 中，恢复购买就是重新检查订阅状态
            await subscriptionManager.updateSubscriptionStatus()
            
            DispatchQueue.main.async {
                if subscriptionManager.isSubscribed {
                    toastManager.showSuccess("已恢复订阅")
                } else {
                    toastManager.showInfo("未找到订阅记录")
                }
            }
        }
    }
    
    /// 重置所有数据
    private func resetAllData() {
        // 1. 清除本地所有诗歌数据
        poemManager.deleteAll()
        
        // 2. 清空笔名
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
        
        toastManager.showSuccess("所有数据已重置")
        
        // 关闭设置页
        dismiss()
    }
}

// MARK: - 编辑笔名视图

struct EditPenNameView: View {
    @Environment(\.dismiss) private var dismiss
    
    let currentName: String
    let onSave: (String) -> Void
    
    @State private var editedName: String
    @FocusState private var isFocused: Bool
    
    init(currentName: String, onSave: @escaping (String) -> Void) {
        self.currentName = currentName
        self.onSave = onSave
        _editedName = State(initialValue: currentName.isEmpty ? "" : currentName)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 输入框
                VStack(alignment: .leading, spacing: 8) {
                    Text("笔名")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                    
                    TextField("给自己起个富有诗意的名字", text: $editedName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Colors.textInk)
                        .padding()
                        .background(Colors.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Colors.border.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isFocused)
                    
                    // 字数统计
                    HStack {
                        Spacer()
                        Text("\(editedName.count)/10")
                            .font(.system(size: 13))
                            .foregroundColor(editedName.count > 10 ? Colors.error : Colors.textTertiary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Colors.backgroundCream)
            .navigationTitle("编辑笔名")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAndDismiss()
                    }
                    .foregroundColor(Colors.accentTeal)
                    .disabled(editedName.count > 10)  // 允许空字符串（会自动保存为"山海诗人"）
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
    private func saveAndDismiss() {
        // 允许空字符串（会在 setPenName 中自动转换为"山海诗人"）
        if editedName.count <= 10 {
            onSave(editedName)
            dismiss()
        }
    }
}

// MARK: - 诗人等级视图

struct PoetTitleView: View {
    @Environment(\.dismiss) private var dismiss
    
    let poemCount: Int
    
    private var currentTitle: PoetTitle {
        PoetTitle.title(forPoemCount: poemCount)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(PoetTitle.allCases, id: \.self) { title in
                        titleRow(title: title, isUnlocked: poemCount >= title.requiredCount, isCurrent: title == currentTitle)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Colors.backgroundCream)
            .navigationTitle("诗人等级")
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
    
    @ViewBuilder
    private func titleRow(title: PoetTitle, isUnlocked: Bool, isCurrent: Bool) -> some View {
        HStack(spacing: 12) {
            // 图标
            Text(title.icon)
                .font(.system(size: 24))
            
            // 称号信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title.displayName)
                        .font(.system(size: 16, weight: isCurrent ? .medium : .regular))
                        .foregroundColor(isCurrent ? Colors.accentTeal : Colors.textInk)
                    
                    if isCurrent {
                        Text("当前")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Colors.accentTeal)
                            .cornerRadius(4)
                    }
                }
                
                Text(title.description)
                    .font(.system(size: 13))
                    .foregroundColor(Colors.textSecondary)
            }
            
            Spacer()
            
            // 解锁状态
            Text(isUnlocked ? "已解锁" : "\(title.requiredCount)首")
                .font(.system(size: 13))
                .foregroundColor(isUnlocked ? Colors.accentTeal : Colors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isCurrent ? Colors.accentTeal.opacity(0.05) : Colors.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCurrent ? Colors.accentTeal.opacity(0.3) : Colors.border.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
