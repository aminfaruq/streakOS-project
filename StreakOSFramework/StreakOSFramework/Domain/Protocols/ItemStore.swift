import Foundation

public protocol ItemStore {
    typealias RetrievalResult = Swift.Result<[Item], Error>
    typealias SaveResult = Swift.Result<Void, Error>
    
    func retrieveAll(completion: @escaping (RetrievalResult) -> Void)
    func save(_ item: Item, completion: @escaping (SaveResult) -> Void)
    func delete(_ item: Item, completion: @escaping (SaveResult) -> Void)
}
