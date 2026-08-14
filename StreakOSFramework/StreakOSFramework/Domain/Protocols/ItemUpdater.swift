import Foundation

public protocol ItemUpdater {
    typealias Result = Swift.Result<Item, Error>
    
    func update(_ item: Item, completion: @escaping (Result) -> Void)
}
