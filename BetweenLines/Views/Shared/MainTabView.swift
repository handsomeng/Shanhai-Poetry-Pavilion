//
//  MainTabView.swift
//  BetweenLines - 字里行间
//
//  主 Tab 视图
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .learning
    
    enum Tab: String, CaseIterable {
        case learning = "学诗", writing = "写诗", explore = "赏诗", library = "我的"
        var iconName: String {
            switch self {
            case .learning: return "book.fill"
            case .writing: return "pencil.and.outline"
            case .explore: return "compass.fill"
            case .library: return "folder.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearningView()
                .tabItem { Label(Tab.learning.rawValue, systemImage: Tab.learning.iconName) }
                .tag(Tab.learning)
            
            WritingView()
                .tabItem { Label(Tab.writing.rawValue, systemImage: Tab.writing.iconName) }
                .tag(Tab.writing)
            
            ExploreView()
                .tabItem { Label(Tab.explore.rawValue, systemImage: Tab.explore.iconName) }
                .tag(Tab.explore)
            
            ProfileView()
                .tabItem { Label(Tab.library.rawValue, systemImage: Tab.library.iconName) }
                .tag(Tab.library)
        }
        .tint(Colors.accentTeal)
    }
}

