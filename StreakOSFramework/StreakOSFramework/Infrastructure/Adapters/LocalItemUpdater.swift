import Foundation

public final class LocalItemUpdater {
    private let itemStore: any ItemStore
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case retrievalFailed
        case duplicateName
        case saveFailed
        case notFound
    }
    
    public init(
        itemStore: any ItemStore,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.itemStore = itemStore
        self.currentDate = currentDate
    }
}

extension LocalItemUpdater: ItemUpdater {
    
    public func update(_ item: Item, completion: @escaping (ItemUpdater.Result) -> Void) {
        itemStore.retrieveAll { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(existingItems):
                guard existingItems.contains(where: { $0.id == item.id }) else {
                    completion(.failure(Error.notFound))
                    return
                }
                guard ItemNameGenerator.isNameUnique(item.name, among: existingItems, excluding: item.id) else {
                    completion(.failure(Error.duplicateName))
                    return
                }
                
                self.save(item, completion: completion)
                
            case .failure:
                completion(.failure(Error.retrievalFailed))
            }
        }
    }
    
    private func save(_ item: Item, completion: @escaping (ItemUpdater.Result) -> Void) {
        let updated = Item(
            id: item.id,
            name: item.name,
            icon: item.icon,
            type: item.type,
            targetCount: item.targetCount,
            startDate: item.startDate,
            endDate: item.endDate,
            displayOrder: item.displayOrder,
            createdAt: item.createdAt,
            updatedAt: currentDate()
        )
        
        itemStore.save(updated) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success:
                completion(.success(updated))
            case .failure:
                completion(.failure(Error.saveFailed))
            }
        }
    }
}
