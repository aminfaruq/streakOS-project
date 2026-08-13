import XCTest
import StreakOSFramework

final class ItemDuplicatorSpy: ItemDuplicator {
    private(set) var receivedMessages = [Message]()

    enum Message: Equatable {
        case duplicate(Item)
    }

    private var duplications = [(ItemDuplicator.Result) -> Void]()

    func duplicate(_ item: Item, completion: @escaping (ItemDuplicator.Result) -> Void) {
        receivedMessages.append(.duplicate(item))
        duplications.append(completion)
    }

    func completeDuplicateSuccessfully(with item: Item, at index: Int = 0) {
        duplications[index](.success(item))
    }

    func completeDuplicate(with error: Error, at index: Int = 0) {
        duplications[index](.failure(error))
    }
}
