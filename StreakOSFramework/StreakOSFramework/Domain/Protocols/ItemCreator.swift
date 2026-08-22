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
        repeatSchedule: RepeatSchedule?,
        completion: @escaping (Result) -> Void
    )
}

public extension ItemCreator {
    func create(
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        completion: @escaping (Result) -> Void
    ) {
        create(
            name: name,
            icon: icon,
            type: type,
            targetCount: targetCount,
            startDate: startDate,
            endDate: endDate,
            repeatSchedule: nil,
            completion: completion
        )
    }
}
