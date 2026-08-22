import Foundation
import SwiftData

@MainActor
public final class SwiftDataItemStore {
    private let modelContainer: ModelContainer?
    private let modelContext: ModelContext
    
    public enum Error: Swift.Error {
        case retrievalError
        case saveError
        case notFound
    }
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    public init(modelContext: ModelContext) {
        self.modelContainer = nil
        self.modelContext = modelContext
    }
}

extension SwiftDataItemStore: ItemStore {
    
    public func retrieveAll(completion: @escaping (ItemStore.RetrievalResult) -> Void) {
        let sortDescriptor = SortDescriptor<SDItem>(\.displayOrder)
        let fetchDescriptor = FetchDescriptor<SDItem>(sortBy: [sortDescriptor])
        
        do {
            let sdItems = try modelContext.fetch(fetchDescriptor)
            let items = SDItemMapper.toDomainList(sdItems)
            completion(.success(items))
        } catch {
            completion(.failure(Error.retrievalError))
        }
    }
    
    public func save(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        do {
            let fetchDescriptor = FetchDescriptor<SDItem>()
            let allItems = try modelContext.fetch(fetchDescriptor)
            
            if let existing = allItems.first(where: { $0.id == item.id }) {
                existing.name = item.name
                existing.icon = item.icon
                existing.itemTypeRawValue = item.type.rawValue
                existing.targetCount = item.targetCount
                existing.startDate = item.startDate
                existing.endDate = item.endDate
                existing.repeatDays = item.repeatSchedule.map { Array($0.days.map(\.rawValue).sorted()) }
                existing.displayOrder = item.displayOrder
                existing.updatedAt = item.updatedAt
            } else {
                let sdItem = SDItemMapper.toSDModel(item)
                modelContext.insert(sdItem)
            }
            
            try modelContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(Error.saveError))
        }
    }
    
    public func delete(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        do {
            let fetchDescriptor = FetchDescriptor<SDItem>()
            let allItems = try modelContext.fetch(fetchDescriptor)
            
            if let existing = allItems.first(where: { $0.id == item.id }) {
                modelContext.delete(existing)
                try modelContext.save()
                completion(.success(()))
            } else {
                completion(.failure(Error.notFound))
            }
        } catch {
            completion(.failure(Error.saveError))
        }
    }
}
