import XCTest
import StreakOSFramework

final class ItemUpdaterSpy: ItemUpdater {
    private(set) var receivedMessages = [Message]()
    
    enum Message: Equatable {
        case update(Item)
        
        var item: Item {
            switch self {
            case .update(let item): return item
            }
        }
    }
    
    private var updateCompletions = [(ItemUpdater.Result) -> Void]()
    
    func update(_ item: Item, completion: @escaping (ItemUpdater.Result) -> Void) {
        receivedMessages.append(.update(item))
        updateCompletions.append(completion)
    }
    
    func completeUpdateSuccessfully(with item: Item, at index: Int = 0) {
        updateCompletions[index](.success(item))
    }
    
    func completeUpdate(with error: Error, at index: Int = 0) {
        updateCompletions[index](.failure(error))
    }
}
