import XCTest
import SwiftData
@testable import StreakOSFramework


@MainActor
final class SwiftDataDailyRecordStoreIntegrationTests: XCTestCase {
    
    private var container: ModelContainer!
    
    override func setUp() {
        super.setUp()
        container = try! StreakOSModelContainer.makeInMemory()
    }
    
    override func tearDown() {
        container = nil
        super.tearDown()
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SwiftDataDailyRecordStore {
        SwiftDataDailyRecordStore(modelContainer: container)
    }
    
    func test_retrieve_noRecord_returnsNil() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieve")
        
        sut.retrieve(for: UUID(), on: Date()) { result in
            switch result {
            case let .success(record):
                XCTAssertNil(record)
            case .failure:
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_saveAndRetrieve_persistsRecord() {
        let sut = makeSUT()
        let itemId = UUID()
        let today = Date()
        let record = DailyRecord(
            id: UUID(),
            itemId: itemId,
            date: today,
            currentCount: 3,
            isCompleted: false,
            timerStartDate: Date(),
            createdAt: today,
            updatedAt: today
        )
        
        let saveExp = expectation(description: "save")
        sut.save(record) { result in
            if case .failure = result { XCTFail("Save failed") }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let retrieveExp = expectation(description: "retrieve")
        sut.retrieve(for: itemId, on: today) { result in
            switch result {
            case let .success(fetched):
                XCTAssertNotNil(fetched)
                XCTAssertEqual(fetched?.itemId, itemId)
                XCTAssertEqual(fetched?.currentCount, 3)
                XCTAssertFalse(fetched?.isCompleted ?? true)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
    
    func test_save_updatesExistingRecord() {
        let sut = makeSUT()
        let itemId = UUID()
        let today = Date()
        let record = DailyRecord(id: UUID(), itemId: itemId, date: today, currentCount: 1, isCompleted: false, timerStartDate: nil, createdAt: today, updatedAt: today)
        
        let save1Exp = expectation(description: "save1")
        sut.save(record) { _ in save1Exp.fulfill() }
        wait(for: [save1Exp], timeout: 1.0)
        
        let updated = DailyRecord(id: record.id, itemId: itemId, date: today, currentCount: 5, isCompleted: true, timerStartDate: today, createdAt: today, updatedAt: Date())
        
        let save2Exp = expectation(description: "save2")
        sut.save(updated) { _ in save2Exp.fulfill() }
        wait(for: [save2Exp], timeout: 1.0)
        
        let retrieveExp = expectation(description: "retrieve")
        sut.retrieve(for: itemId, on: today) { result in
            switch result {
            case let .success(fetched):
                XCTAssertNotNil(fetched)
                XCTAssertEqual(fetched?.currentCount, 5)
                XCTAssertTrue(fetched?.isCompleted ?? false)
                XCTAssertEqual(fetched?.timerStartDate, today)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
    
    func test_retrieve_differentDate_returnsNil() {
        let sut = makeSUT()
        let itemId = UUID()
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let record = DailyRecord(id: UUID(), itemId: itemId, date: today, currentCount: 2, isCompleted: false, timerStartDate: nil, createdAt: today, updatedAt: today)
        let saveExp = expectation(description: "save")
        sut.save(record) { _ in saveExp.fulfill() }
        wait(for: [saveExp], timeout: 1.0)
        
        let retrieveExp = expectation(description: "retrieve")
        sut.retrieve(for: itemId, on: tomorrow) { result in
            switch result {
            case let .success(fetched):
                XCTAssertNil(fetched)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
    
    func test_retrieveAll_emptyStore_returnsEmptyList() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieveAll")
        
        sut.retrieveAll(for: Date()) { result in
            switch result {
            case let .success(records):
                XCTAssertTrue(records.isEmpty)
            case .failure:
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAll_returnsRecordsForDate() {
        let sut = makeSUT()
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let todayRecord = DailyRecord(id: UUID(), itemId: UUID(), date: today, currentCount: 1, isCompleted: false, timerStartDate: nil, createdAt: today, updatedAt: today)
        let tomorrowRecord = DailyRecord(id: UUID(), itemId: UUID(), date: tomorrow, currentCount: 5, isCompleted: true, timerStartDate: nil, createdAt: tomorrow, updatedAt: tomorrow)
        
        let save1Exp = expectation(description: "save1")
        sut.save(todayRecord) { _ in save1Exp.fulfill() }
        wait(for: [save1Exp], timeout: 1.0)
        
        let save2Exp = expectation(description: "save2")
        sut.save(tomorrowRecord) { _ in save2Exp.fulfill() }
        wait(for: [save2Exp], timeout: 1.0)
        
        let retrieveExp = expectation(description: "retrieve")
        sut.retrieveAll(for: today) { result in
            switch result {
            case let .success(records):
                XCTAssertEqual(records.count, 1)
                XCTAssertEqual(records[0].itemId, todayRecord.itemId)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
}
