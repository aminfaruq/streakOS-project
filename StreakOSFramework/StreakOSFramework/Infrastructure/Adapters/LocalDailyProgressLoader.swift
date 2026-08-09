import Foundation

public final class LocalDailyProgressLoader {
    private let itemStore: any ItemStore
    private let dailyRecordStore: any DailyRecordStore

    public enum Error: Swift.Error {
        case itemRetrievalFailed
        case recordRetrievalFailed
    }

    public init(
        itemStore: any ItemStore,
        dailyRecordStore: any DailyRecordStore
    ) {
        self.itemStore = itemStore
        self.dailyRecordStore = dailyRecordStore
    }
}

extension LocalDailyProgressLoader: DailyProgressLoader {

    public func load(for date: Date, completion: @escaping (DailyProgressLoader.Result) -> Void) {
        itemStore.retrieveAll { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(items):
                self.loadRecords(for: date, items: items, completion: completion)

            case .failure:
                completion(.failure(Error.itemRetrievalFailed))
            }
        }
    }

    private func loadRecords(
        for date: Date,
        items: [Item],
        completion: @escaping (DailyProgressLoader.Result) -> Void
    ) {
        dailyRecordStore.retrieveAll(for: date) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(records):
                let progress = self.makeProgress(items: items, records: records, on: date)
                completion(.success(progress))
            case .failure:
                completion(.failure(Error.recordRetrievalFailed))
            }
        }
    }

    private func makeProgress(items: [Item], records: [DailyRecord], on date: Date) -> [ItemProgress] {
        let visibleItems = items.filter { $0.isVisible(on: date) }
        return visibleItems.map { item in
            let record = records.first { $0.itemId == item.id }
            return ItemProgress(item: item, record: record)
        }
    }
}