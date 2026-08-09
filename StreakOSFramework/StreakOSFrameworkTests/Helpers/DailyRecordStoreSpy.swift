import XCTest
@testable import StreakOSFramework

final class DailyRecordStoreSpy: DailyRecordStore {
    enum ReceivedMessage: Equatable {
        case retrieve(itemId: UUID, date: Date)
        case retrieveAll(date: Date)
        case save(DailyRecord)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var retrievalCompletions = [(DailyRecordStore.RetrievalResult) -> Void]()
    private var retrievalAllCompletions = [(DailyRecordStore.RetrievalAllResult) -> Void]()
    private var saveCompletions = [(DailyRecordStore.SaveResult) -> Void]()
    
    func retrieve(for itemId: UUID, on date: Date, completion: @escaping (DailyRecordStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(itemId: itemId, date: date))
        retrievalCompletions.append(completion)
    }
    
    func retrieveAll(for date: Date, completion: @escaping (DailyRecordStore.RetrievalAllResult) -> Void) {
        receivedMessages.append(.retrieveAll(date: date))
        retrievalAllCompletions.append(completion)
    }
    
    func save(_ record: DailyRecord, completion: @escaping (DailyRecordStore.SaveResult) -> Void) {
        receivedMessages.append(.save(record))
        saveCompletions.append(completion)
    }
    
    func completeRetrieval(with record: DailyRecord?, at index: Int = 0) {
        retrievalCompletions[index](.success(record))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalAll(with records: [DailyRecord], at index: Int = 0) {
        retrievalAllCompletions[index](.success(records))
    }
    
    func completeRetrievalAll(with error: Error, at index: Int = 0) {
        retrievalAllCompletions[index](.failure(error))
    }
    
    func completeSaveSuccessfully(at index: Int = 0) {
        saveCompletions[index](.success(()))
    }
    
    func completeSave(with error: Error, at index: Int = 0) {
        saveCompletions[index](.failure(error))
    }
}
