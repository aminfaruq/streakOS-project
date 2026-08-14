import Foundation

public protocol DailyProgressLoader {
    typealias Result = Swift.Result<[ItemProgress], Error>
    func load(for date: Date, completion: @escaping (Result) -> Void)
}