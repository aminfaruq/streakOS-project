import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// Composition root for the macOS SwiftUI app.
/// Pure-SwiftUI variant: the `@main App` owns this and injects dependencies into views.
@MainActor
enum AppComposer {

    static func makeViewModel() throws -> ProgressFeedViewModel {
        let container = try StreakOSModelContainer.makeCloudKitEnabled()

        let itemStore = SwiftDataItemStore(modelContainer: container)
        let recordStore = SwiftDataDailyRecordStore(modelContainer: container)

        let loader = LocalDailyProgressLoader(itemStore: itemStore, dailyRecordStore: recordStore)
        let tracker = LocalProgressTracker(store: recordStore)

        return ProgressFeedViewModel(loader: loader, tracker: tracker)
    }
}
