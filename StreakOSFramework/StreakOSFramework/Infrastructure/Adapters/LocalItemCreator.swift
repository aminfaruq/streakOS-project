import Foundation

public final class LocalItemCreator {
    private let itemStore: any ItemStore
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case retrievalFailed
        case duplicateName
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

extension LocalItemCreator: ItemCreator {
    
    public func create(
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        repeatSchedule: RepeatSchedule?,
        completion: @escaping (ItemCreator.Result) -> Void
    ) {
        itemStore.retrieveAll { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(existingItems):
                guard ItemNameGenerator.isNameUnique(name, among: existingItems) else {
                    completion(.failure(Error.duplicateName))
                    return
                }
                
                let item = self.makeItem(
                    name: name,
                    icon: icon,
                    type: type,
                    targetCount: targetCount,
                    startDate: startDate,
                    endDate: endDate,
                    repeatSchedule: repeatSchedule,
                    existingItems: existingItems
                )
                self.save(item, completion: completion)
                
            case .failure:
                completion(.failure(Error.retrievalFailed))
            }
        }
    }
    
    private func save(_ item: Item, completion: @escaping (ItemCreator.Result) -> Void) {
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
    
    private func makeItem(
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        repeatSchedule: RepeatSchedule?,
        existingItems: [Item]
    ) -> Item {
        let now = currentDate()
        let topOrder = (existingItems.map(\.displayOrder).min() ?? 0) - 1
        return Item(
            id: UUID(),
            name: name,
            icon: icon,
            type: type,
            targetCount: targetCount,
            startDate: startDate,
            endDate: endDate,
            repeatSchedule: repeatSchedule,
            displayOrder: topOrder,
            createdAt: now,
            updatedAt: now
        )
    }
}
