import Foundation
import Combine
import StreakOSFramework

@MainActor
public final class ProgressFeedViewModel: ObservableObject {
    @Published public private(set) var progressItems: [ItemProgress] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?
    
    private let loader: any DailyProgressLoader
    private var loadTask: Task<Void, Never>?
    
    public init(loader: any DailyProgressLoader) {
        self.loader = loader
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
    
    public func cancel() {
        loadTask?.cancel()
        loadTask = nil
        isLoading = false
    }
    
    deinit {
        loadTask?.cancel()
    }
}
