//
//  StreakOSWatchAppApp.swift
//  StreakOSWatchApp Watch App
//
//  Created by Amin faruq on 13/08/26.
//

import SwiftUI
import StreakOSFramework
import StreakOSPresentation

@main
struct StreakOSWatchApp_Watch_AppApp: App {
    @StateObject private var viewModel: ProgressFeedViewModel
    private let itemCreator: any ItemCreator
    private let itemUpdater: any ItemUpdater
    private let itemDuplicator: any ItemDuplicator
    
    init() {
        do {
            let deps = try AppComposer.makeDependencies()
            _viewModel = StateObject(wrappedValue: deps.viewModel)
            self.itemCreator = deps.itemCreator
            self.itemUpdater = deps.itemUpdater
            self.itemDuplicator = deps.itemDuplicator
        } catch {
            fatalError("Failed to bootstrap StreakOS Watch App: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WatchProgressListView(viewModel: viewModel)
        }
    }
}
