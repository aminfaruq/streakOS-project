import Foundation
import Combine
import StreakOSFramework

@MainActor
public final class ProgressFeedViewModel: ObservableObject {
    @Published public private(set) var progressItems: [ItemProgress] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let loader: any DailyProgressLoader
    private let tracker: (any ProgressTracker)?
    private let itemStore: (any ItemStore)?
    private var loadTask: Task<Void, Never>?

    public init(
        loader: any DailyProgressLoader,
        tracker: (any ProgressTracker)?,
        itemStore: (any ItemStore)?
    ) {
        self.loader = loader
        self.tracker = tracker
        self.itemStore = itemStore
    }

    public func load(for date: Date = Date()) {
        loadTask?.cancel()

        isLoading = true
        errorMessage = nil

        let loader = self.loader
        loadTask = Task { [weak self] in
            let result = await withCheckedContinuation { continuation in
                loader.load(for: date) { continuation.resume(returning: $0) }
            }

            guard !Task.isCancelled, let self else { return }

            switch result {
            case let .success(items):
                progressItems = items
            case .failure:
                progressItems = []
                errorMessage = "Failed to load progress"
            }
            isLoading = false
        }
    }

    public func increment(_ progress: ItemProgress, on date: Date = Date()) {
        guard let tracker else { return }
        tracker.increment(progress.item, on: date) { [weak self] result in
            self?.apply(result) { updatedRecord in
                self?.replace(progress, with: updatedRecord)
            }
        }
    }

    public func decrement(_ progress: ItemProgress, on date: Date = Date()) {
        guard let tracker else { return }
        tracker.decrement(progress.item, on: date) { [weak self] result in
            self?.apply(result) { updatedRecord in
                self?.replace(progress, with: updatedRecord)
            }
        }
    }

    public func delete(_ progress: ItemProgress, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let itemStore else { return }
        itemStore.delete(progress.item) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                progressItems.removeAll { $0.item.id == progress.item.id }
            case .failure:
                errorMessage = "Failed to delete item"
            }
            completion?(result)
        }
    }

    public func cancel() {
        loadTask?.cancel()
        loadTask = nil
        isLoading = false
    }

    private func apply(
        _ result: ProgressTracker.Result,
        onSuccess update: @escaping (DailyRecord) -> Void
    ) {
        switch result {
        case let .success(record):
            update(record)
        case .failure:
            errorMessage = "Failed to update progress"
        }
    }

    private func replace(_ progress: ItemProgress, with record: DailyRecord) {
        guard let index = progressItems.firstIndex(where: { $0.item.id == progress.item.id }) else {
            return
        }
        progressItems[index] = ItemProgress(item: progress.item, record: record)
    }

    deinit {
        loadTask?.cancel()
    }
}