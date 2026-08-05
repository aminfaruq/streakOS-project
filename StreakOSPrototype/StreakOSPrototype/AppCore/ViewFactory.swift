//
//  ViewFactory.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import SwiftUI

@MainActor
struct ViewFactory {
    
    let container: DependencyContainer
    
    
    func makeRootView() -> RootView {
        RootView()
    }
    
    func makeHabitsTab() -> HabitsTab {
        HabitsTab()
    }
    
    func makeStasticsTab() -> StatisticsTab {
        StatisticsTab()
    }
    
    func makeSettingsTab() -> SettingsTab {
        SettingsTab()
    }
}
