import SwiftUI
import StreakOSFramework
import StreakOSPresentation

@main
struct StreakOSMacApp: App {
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate
    
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
            .frame(width: 430)
            .frame(minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        MenuBarExtra("StreakOS", systemImage: "checkmark.circle") {
            MenuBarProgressView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
    
}

class MacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.registerForRemoteNotifications()
    }
}
