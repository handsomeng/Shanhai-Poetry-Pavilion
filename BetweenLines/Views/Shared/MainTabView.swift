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
            case .learning: return "book"                      // 学诗：打开的书，学习感
            case .writing: return "pencil.line"                // 写诗：线性铅笔，书写感
            case .explore: return "text.book.closed"           // 赏诗：诗集，欣赏阅读
            case .library: return "person"                     // 我的：简洁人物，个人中心
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearningView()
                .tabItem { Label(Tab.learning.rawValue, systemImage: Tab.learning.iconName) }
                .tag(Tab.learning)
                .environmentObject(tabManager)
            
            WritingView()
                .tabItem { Label(Tab.writing.rawValue, systemImage: Tab.writing.iconName) }
                .tag(Tab.writing)
                .environmentObject(tabManager)
            
            ExploreView()
                .tabItem { Label(Tab.explore.rawValue, systemImage: Tab.explore.iconName) }
                .tag(Tab.explore)
                .environmentObject(tabManager)
            
            ProfileView()
                .tabItem { Label(Tab.library.rawValue, systemImage: Tab.library.iconName) }
                .tag(Tab.library)
                .environmentObject(tabManager)
        }
        .tint(Colors.accentTeal)
        .onChange(of: tabManager.selectedTab) {
            selectedTab = tabManager.selectedTab
        }
    }
}

