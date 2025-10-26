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
        case learning = "学诗", collection = "诗集"
        var iconName: String {
            switch self {
            case .learning: return "book"                      // 学诗：打开的书，学习感
            case .collection: return "text.book.closed"        // 诗集：诗集图标，收藏感
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearningView()
                .tabItem { Label(Tab.learning.rawValue, systemImage: Tab.learning.iconName) }
                .tag(Tab.learning)
                .environmentObject(tabManager)
            
            PoetryCollectionView()
                .tabItem { Label(Tab.collection.rawValue, systemImage: Tab.collection.iconName) }
                .tag(Tab.collection)
                .environmentObject(tabManager)
        }
        .tint(Colors.accentTeal)
        .onChange(of: tabManager.selectedTab) {
            selectedTab = tabManager.selectedTab
        }
    }
}

