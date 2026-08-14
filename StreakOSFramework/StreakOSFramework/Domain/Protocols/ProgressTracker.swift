import Foundation

public protocol ProgressTracker {
    typealias Result = Swift.Result<DailyRecord, Error>
    
    func increment(_ item: Item, on date: Date, completion: @escaping (Result) -> Void)
    func decrement(_ item: Item, on date: Date, completion: @escaping (Result) -> Void)
    func toggleTimer(_ item: Item, on date: Date, completion: @escaping (Result) -> Void)
    func restart(_ item: Item, on date: Date, completion: @escaping (Result) -> Void)
}
