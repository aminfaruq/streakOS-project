import Foundation
import SwiftData

@MainActor
public final class SwiftDataDailyRecordStore {
    private let modelContainer: ModelContainer?
    private let modelContext: ModelContext
    
    public enum Error: Swift.Error {
        case retrievalError
        case saveError
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

extension SwiftDataDailyRecordStore: DailyRecordStore {
    
    public func retrieve(
        for itemId: UUID,
        on date: Date,
        completion: @escaping (DailyRecordStore.RetrievalResult) -> Void
    ) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let fetchDescriptor = FetchDescriptor<SDDailyRecord>()
            let allRecords = try modelContext.fetch(fetchDescriptor)
            let match = allRecords.first {
                $0.itemId == itemId && $0.date >= startOfDay && $0.date < endOfDay
            }
            
            if let match {
                completion(.success(SDDailyRecordMapper.toDomain(match)))
            } else {
                completion(.success(nil))
            }
        } catch {
            completion(.failure(Error.retrievalError))
        }
    }
    
    public func retrieveAll(
        for date: Date,
        completion: @escaping (DailyRecordStore.RetrievalAllResult) -> Void
    ) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let fetchDescriptor = FetchDescriptor<SDDailyRecord>()
            let allRecords = try modelContext.fetch(fetchDescriptor)
            let matches = allRecords.filter { $0.date >= startOfDay && $0.date < endOfDay }
            completion(.success(SDDailyRecordMapper.toDomainList(matches)))
        } catch {
            completion(.failure(Error.retrievalError))
        }
    }
    
    public func save(
        _ record: DailyRecord,
        completion: @escaping (DailyRecordStore.SaveResult) -> Void
    ) {
        let startOfDay = Calendar.current.startOfDay(for: record.date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            let fetchDescriptor = FetchDescriptor<SDDailyRecord>()
            let allRecords = try modelContext.fetch(fetchDescriptor)
            
            if let existing = allRecords.first(where: {
                $0.itemId == record.itemId && $0.date >= startOfDay && $0.date < endOfDay
            }) {
                existing.currentCount = record.currentCount
                existing.isCompleted = record.isCompleted
                existing.updatedAt = record.updatedAt
            } else {
                let sdRecord = SDDailyRecordMapper.toSDModel(record)
                modelContext.insert(sdRecord)
            }
            
            try modelContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(Error.saveError))
        }
    }
}
