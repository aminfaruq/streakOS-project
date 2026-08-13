import SwiftUI
import StreakOSFramework
import StreakOSPresentation

@main
struct StreakOSMacAppApp: App {
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
            fatalError("Failed to bootstrap StreakOS: \(error)")
        }
    }
    
    var body: some Scene {
        Window("StreakOS", id: "main") {
            ProgressListView(
                viewModel: viewModel,
                itemCreator: itemCreator,
                itemUpdater: itemUpdater,
                itemDuplicator: itemDuplicator
            )
            .frame(minWidth: 400, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        
        MenuBarExtra("StreakOS", systemImage: "checkmark.circle") {
            MenuBarProgressView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
    
}
