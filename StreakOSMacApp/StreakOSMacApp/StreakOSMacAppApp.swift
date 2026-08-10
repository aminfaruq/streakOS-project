import SwiftUI
import StreakOSFramework
import StreakOSPresentation

@main
struct StreakOSMacAppApp: App {
    @StateObject private var viewModel: ProgressFeedViewModel
    private let itemCreator: any ItemCreator

    init() {
        do {
            let deps = try AppComposer.makeDependencies()
            _viewModel = StateObject(wrappedValue: deps.viewModel)
            self.itemCreator = deps.itemCreator
        } catch {
            fatalError("Failed to bootstrap StreakOS: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ProgressListView(viewModel: viewModel, itemCreator: itemCreator)
                .frame(minWidth: 400, minHeight: 700)
        }
    }
}
