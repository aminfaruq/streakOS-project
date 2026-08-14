import SwiftUI
import StreakOSFramework
import StreakOSPresentation
import CoreData

struct WatchProgressListView: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.progressItems.isEmpty {
                    Text("No habits for today.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.progressItems, id: \.item.id) { progress in
                        WatchItemRow(
                            progress: progress,
                            onIncrement: { viewModel.increment(progress, on: Date()) },
                            onDecrement: { viewModel.decrement(progress, on: Date()) },
                            onToggleTimer: { viewModel.toggleTimer(for: progress, on: Date()) }
                        )
                    }
                }
            }
            .navigationTitle("StreakOS")
            .onAppear {
                viewModel.load(for: Date())
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
                    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            ) { _ in
                viewModel.load(for: Date())
            }
        }
    }
}
