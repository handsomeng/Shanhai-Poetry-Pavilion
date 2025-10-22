//
//  TabManager.swift
//  山海诗馆
//
//  Tab 导航管理器：支持跨 Tab 跳转
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var selectedTab: MainTabView.Tab = .learning
    
    func switchTo(_ tab: MainTabView.Tab) {
        selectedTab = tab
    }
}

