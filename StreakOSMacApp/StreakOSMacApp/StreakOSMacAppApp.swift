import SwiftUI
import StreakOSFramework
import StreakOSPresentation

@main
struct StreakOSMacAppApp: App {
    @StateObject private var viewModel: ProgressFeedViewModel

    init() {
        do {
            let viewModel = try AppComposer.makeViewModel()
            _viewModel = StateObject(wrappedValue: viewModel)
        } catch {
            fatalError("Failed to bootstrap StreakOS: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ProgressListView(viewModel: viewModel)
                .frame(minWidth: 400, minHeight: 700)
        }
    }
}
