import XCTest
import StreakOSFramework

final class ItemStoreSpy: ItemStore {
    private(set) var receivedMessages = [Message]()

    enum Message: Equatable {
        case retrieveAll
        case save(Item)
        case delete(Item)
    }

    private var deletionCompletions = [(ItemStore.SaveResult) -> Void]()

    func retrieveAll(completion: @escaping (ItemStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieveAll)
    }

    func save(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        receivedMessages.append(.save(item))
    }

    func delete(_ item: Item, completion: @escaping (ItemStore.SaveResult) -> Void) {
        receivedMessages.append(.delete(item))
        deletionCompletions.append(completion)
    }

    func completeDeleteSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    func completeDelete(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
}