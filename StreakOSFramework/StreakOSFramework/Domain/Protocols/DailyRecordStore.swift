import Foundation

public protocol DailyRecordStore {
    typealias RetrievalResult = Swift.Result<DailyRecord?, Error>
    typealias RetrievalAllResult = Swift.Result<[DailyRecord], Error>
    typealias SaveResult = Swift.Result<Void, Error>

    func retrieve(for itemId: UUID, on date: Date, completion: @escaping (RetrievalResult) -> Void)
    func retrieveAll(for date: Date, completion: @escaping (RetrievalAllResult) -> Void)
    func save(_ record: DailyRecord, completion: @escaping (SaveResult) -> Void)
}
