import Foundation

public protocol ItemDuplicator {
    typealias Result = Swift.Result<Item, Error>
    
    func duplicate(_ item: Item, completion: @escaping (Result) -> Void)
}
