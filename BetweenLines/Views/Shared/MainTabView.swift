//
//  MainTabView.swift
//  BetweenLines - 字里行间
//
//  主 Tab 视图
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var tabManager = TabManager()
    
    @State private var selectedTab: Tab = .learning
    
    enum Tab: String, CaseIterable {
        case learning = "学诗", writing = "写诗", explore = "赏诗", library = "我的"
        var iconName: String {
            switch self {
            case .learning: return "TabIconLearn"      // 学诗：书本图标
            case .writing: return "TabIconWrite"       // 写诗：羽毛笔图标
            case .explore: return "TabIconExplore"     // 赏诗：山海图标
            case .library: return "TabIconProfile"     // 我的：人物图标
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearningView()
                .tabItem { Label(Tab.learning.rawValue, image: Tab.learning.iconName) }
                .tag(Tab.learning)
                .environmentObject(tabManager)
            
            WritingView()
                .tabItem { Label(Tab.writing.rawValue, image: Tab.writing.iconName) }
                .tag(Tab.writing)
                .environmentObject(tabManager)
            
            ExploreView()
                .tabItem { Label(Tab.explore.rawValue, image: Tab.explore.iconName) }
                .tag(Tab.explore)
                .environmentObject(tabManager)
            
            ProfileView()
                .tabItem { Label(Tab.library.rawValue, image: Tab.library.iconName) }
                .tag(Tab.library)
                .environmentObject(tabManager)
        }
        .tint(Colors.accentTeal)
        .onChange(of: tabManager.selectedTab) {
            selectedTab = tabManager.selectedTab
        }
    }
}

