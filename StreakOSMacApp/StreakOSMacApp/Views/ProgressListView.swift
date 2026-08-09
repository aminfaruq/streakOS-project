import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// PRD §9.1/§9.5 main progress screen.
struct ProgressListView: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    @State private var selectedDate = Date()

    private var navigationWindow: DateNavigationWindow {
        DateNavigationWindow(today: Date())
    }

    var body: some View {
        VStack(spacing: 16) {
            DateHeaderView(
                title: titleText,
                isToday: navigationWindow.isToday(selectedDate),
                canGoBackward: navigationWindow.canNavigateBackward(from: selectedDate),
                canGoForward: navigationWindow.canNavigateForward(from: selectedDate),
                onBackward: { shiftDay(by: -1) },
                onForward: { shiftDay(by: 1) },
                onToday: { selectedDate = Date() }
            )

            if viewModel.isLoading && viewModel.progressItems.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.progressItems.isEmpty {
                emptyState
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.progressItems, id: \.item.id) { progress in
                            ItemCardView(
                                progress: progress,
                                onIncrement: { viewModel.increment(progress, on: selectedDate) },
                                onDecrement: { viewModel.decrement(progress, on: selectedDate) }
                            )
                        }
                    }
                    .padding(4)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(DesignTokens.background)
        .onAppear {
            viewModel.load(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            viewModel.load(for: newDate)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📋")
                .font(.system(size: 56))
            Text("No habits yet")
                .font(.title3.weight(.semibold))
            Text("Add your first habit to get started")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }

    private var titleText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return navigationWindow.isToday(selectedDate) ? "Today · \(formatter.string(from: selectedDate))" : formatter.string(from: selectedDate)
    }

    private func shiftDay(by offset: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: offset, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
