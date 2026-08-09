import XCTest
@testable import StreakOSFramework

final class ItemStoreSpy: ItemStore {
    enum ReceivedMessage: Equatable {
        case retrieveAll
        case save(Item)
        case delete(Item)
    }

    private(set) var receivedMessages = [ReceivedMessage]()

    private var retrievalCompletions = [(ItemStore.RetrievalResult) -> Void]()
    private var saveCompletions = [(ItemStore.SaveResult) -> Void]()
    private var deleteCompletions = [(ItemStore.SaveResult) -> Void]()

    func retrieveAll(completion: @escaping (ItemStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieveAll)
        retrievalCompletions.append(completion)
    }

    func save(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        receivedMessages.append(.save(item))
        saveCompletions.append(completion)
    }

    func delete(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        receivedMessages.append(.delete(item))
        deleteCompletions.append(completion)
    }

    func completeRetrieval(with items: [Item], at index: Int = 0) {
        retrievalCompletions[index](.success(items))
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeSaveSuccessfully(at index: Int = 0) {
        saveCompletions[index](.success(()))
    }

    func completeSave(with error: Error, at index: Int = 0) {
        saveCompletions[index](.failure(error))
    }

    func completeDeleteSuccessfully(at index: Int = 0) {
        deleteCompletions[index](.success(()))
    }

    func completeDelete(with error: Error, at index: Int = 0) {
        deleteCompletions[index](.failure(error))
    }
}
