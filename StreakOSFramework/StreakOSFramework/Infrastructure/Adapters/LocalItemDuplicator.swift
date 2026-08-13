import Foundation

public final class LocalItemDuplicator {
    private let itemStore: any ItemStore
    private let currentDate: () -> Date

    public enum Error: Swift.Error {
        case retrievalFailed
        case saveFailed
    }

    public init(
        itemStore: any ItemStore,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.itemStore = itemStore
        self.currentDate = currentDate
    }
}

extension LocalItemDuplicator: ItemDuplicator {

    public func duplicate(_ item: Item, completion: @escaping (ItemDuplicator.Result) -> Void) {
        itemStore.retrieveAll { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(existingItems):
                let duplicate = self.makeDuplicate(of: item, among: existingItems)
                self.save(duplicate, completion: completion)

            case .failure:
                completion(.failure(Error.retrievalFailed))
            }
        }
    }

    private func save(_ item: Item, completion: @escaping (ItemDuplicator.Result) -> Void) {
        itemStore.save(item) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success:
                completion(.success(item))
            case .failure:
                completion(.failure(Error.saveFailed))
            }
        }
    }

    private func makeDuplicate(of item: Item, among existingItems: [Item]) -> Item {
        let now = currentDate()
        let topOrder = (existingItems.map(\.displayOrder).min() ?? 0) - 1
        return Item(
            id: UUID(),
            name: ItemNameGenerator.duplicateName(for: item.name, among: existingItems),
            icon: item.icon,
            targetCount: item.targetCount,
            startDate: now,
            endDate: item.endDate,
            displayOrder: topOrder,
            createdAt: now,
            updatedAt: now
        )
    }
}