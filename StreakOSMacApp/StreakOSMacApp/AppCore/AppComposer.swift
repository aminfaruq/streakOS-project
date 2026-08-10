import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// Composition root for the macOS SwiftUI app.
/// Pure-SwiftUI variant: the `@main App` owns this and injects dependencies into views.
@MainActor
enum AppComposer {

    struct Dependencies {
        let viewModel: ProgressFeedViewModel
        let itemCreator: any ItemCreator
    }

    static func makeDependencies() throws -> Dependencies {
        let container = try StreakOSModelContainer.makeCloudKitEnabled()

        let itemStore = SwiftDataItemStore(modelContainer: container)
        let recordStore = SwiftDataDailyRecordStore(modelContainer: container)

        let loader = LocalDailyProgressLoader(itemStore: itemStore, dailyRecordStore: recordStore)
        let tracker = LocalProgressTracker(store: recordStore)
        let creator = LocalItemCreator(itemStore: itemStore)

        return Dependencies(
            viewModel: ProgressFeedViewModel(loader: loader, tracker: tracker),
            itemCreator: creator
        )
    }
}
