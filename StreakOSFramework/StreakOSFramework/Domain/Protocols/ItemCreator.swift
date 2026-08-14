import Foundation

public protocol ItemCreator {
    typealias Result = Swift.Result<Item, Error>
    
    func create(
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        completion: @escaping (Result) -> Void
    )
}
