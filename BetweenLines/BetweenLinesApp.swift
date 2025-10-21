//
//  BetweenLinesApp.swift
//  BetweenLines - 字里行间
//
//  应用入口
//

import SwiftUI

@main
struct BetweenLinesApp: App {
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .preferredColorScheme(.light)
            } else {
                LandingView(onComplete: {
                    hasCompletedOnboarding = true
                })
                .preferredColorScheme(.light)
            }
        }
    }
}
