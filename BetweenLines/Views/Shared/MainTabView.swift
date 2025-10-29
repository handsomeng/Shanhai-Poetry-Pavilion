//
//  MainTabView.swift
//  BetweenLines - 字里行间
//
//  主视图 - 诗集页面（已移除 Tab 栏）
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        // 直接显示诗集页面，不再使用 TabView
        PoetryCollectionView()
    }
}

