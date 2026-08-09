import Foundation

public protocol DailyRecordStore {
    typealias RetrievalResult = Swift.Result<DailyRecord?, Error>
    typealias SaveResult = Swift.Result<Void, Error>

    func retrieve(for itemId: UUID, on date: Date, completion: @escaping (RetrievalResult) -> Void)
    func save(_ record: DailyRecord, completion: @escaping (SaveResult) -> Void)
}
