import Foundation

public final class LocalProgressTracker {
    private let store: any DailyRecordStore
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case retrievalFailed
        case saveFailed
        case dateNotEditable
    }
    
    public init(store: any DailyRecordStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalProgressTracker: ProgressTracker {
    
    public func increment(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        guard isEditable(date) else {
            completion(.failure(Error.dateNotEditable))
            return
        }
        
        apply(item, on: date, transform: { $0.incrementing(targetCount: item.targetCount) }, completion: completion)
    }
    
    public func decrement(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        guard isEditable(date) else {
            completion(.failure(Error.dateNotEditable))
            return
        }
        
        apply(item, on: date, transform: { $0.decrementing(targetCount: item.targetCount) }, completion: completion)
    }
    
    private func isEditable(_ date: Date) -> Bool {
        DateNavigationWindow(today: currentDate()).accessibility(of: date) == .editable
    }
    
    private func apply(
        _ item: Item,
        on date: Date,
        transform: @escaping (DailyRecord) -> DailyRecord,
        completion: @escaping (ProgressTracker.Result) -> Void
    ) {
        store.retrieve(for: item.id, on: date) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(existing):
                let current = existing ?? DailyRecord.new(for: item.id, on: date)
                let updated = transform(current)
                self.store.save(updated) { saveResult in
                    switch saveResult {
                    case .success:
                        completion(.success(updated))
                    case .failure:
                        completion(.failure(Error.saveFailed))
                    }
                }
                
            case .failure:
                completion(.failure(Error.retrievalFailed))
            }
        }
    }
}
