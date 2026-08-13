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
    private let updater: (any ItemUpdater)?
    private let duplicator: (any ItemDuplicator)?
    private var loadTask: Task<Void, Never>?
    
    public init(
        loader: any DailyProgressLoader,
        tracker: (any ProgressTracker)?,
        itemStore: (any ItemStore)?,
        updater: (any ItemUpdater)? = nil,
        duplicator: (any ItemDuplicator)? = nil
    ) {
        self.loader = loader
        self.tracker = tracker
        self.itemStore = itemStore
        self.updater = updater
        self.duplicator = duplicator
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
    
    public func duplicate(_ progress: ItemProgress, on date: Date = Date()) {
        guard let duplicator else { return }
        duplicator.duplicate(progress.item) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                load(for: date)
            case .failure:
                errorMessage = "Failed to duplicate item"
            }
        }
    }
    
    public func update(_ progress: ItemProgress, with item: Item, on date: Date = Date()) {
        guard let updater else { return }
        updater.update(item) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                load(for: date)
            case .failure:
                errorMessage = "Failed to update item"
            }
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
    
    public func reorder(from sourceIndex: Int, to destinationIndex: Int, on date: Date = Date()) {
        guard progressItems.indices.contains(sourceIndex), progressItems.indices.contains(destinationIndex) else { return }
        
        let items = progressItems.map { $0.item }
        let reorderedItems = ItemReorder.reorder(items: items, fromIndex: sourceIndex, toIndex: destinationIndex)
        
        var newProgressItems: [ItemProgress] = []
        for item in reorderedItems {
            if let existing = progressItems.first(where: { $0.item.id == item.id }) {
                newProgressItems.append(ItemProgress(item: item, record: existing.record))
            }
        }
        self.progressItems = newProgressItems
        
        guard let updater = self.updater else { return }
        
        Task { [weak self] in
            for item in reorderedItems {
                await withCheckedContinuation { continuation in
                    updater.update(item) { _ in continuation.resume() }
                }
            }
            await MainActor.run {
                self?.load(for: date)
            }
        }
    }
    
    public func updateItemsLocally(_ items: [ItemProgress]) {
        self.progressItems = items
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
