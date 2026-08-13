import XCTest
@testable import StreakOSFramework

final class LocalDailyProgressLoaderTests: XCTestCase {
    
    func test_load_retrievesItemsThenRecords() {
        let (sut, itemStore, recordStore) = makeSUT()
        let date = Date()
        
        sut.load(for: date) { _ in }
        
        XCTAssertEqual(itemStore.receivedMessages, [.retrieveAll])
        XCTAssertTrue(recordStore.receivedMessages.isEmpty)
        
        itemStore.completeRetrieval(with: [])
        XCTAssertEqual(recordStore.receivedMessages, [.retrieveAll(date: date)])
    }
    
    func test_load_deliversErrorOnItemRetrievalFailure() {
        let (sut, itemStore, _) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalDailyProgressLoader.Error.itemRetrievalFailed)) {
            itemStore.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnRecordRetrievalFailure() {
        let (sut, itemStore, recordStore) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalDailyProgressLoader.Error.recordRetrievalFailed)) {
            itemStore.completeRetrieval(with: [])
            recordStore.completeRetrievalAll(with: anyNSError())
        }
    }
    
    func test_load_deliversEmptyProgressWhenNoVisibleItems() {
        let (sut, itemStore, recordStore) = makeSUT()
        let date = Date()
        
        expect(sut, for: date, toCompleteWith: .success([])) {
            itemStore.completeRetrieval(with: [])
            recordStore.completeRetrievalAll(with: [])
        }
    }
    
    func test_load_filtersOutItemsNotVisibleOnDate() {
        let (sut, itemStore, recordStore) = makeSUT()
        let date = Date()
        
        let visible = uniqueItem(startDate: date.adding(days: -1))
        let hidden = uniqueItem(startDate: date.adding(days: 1))
        
        expect(sut, for: date, toCompleteWith: .success([ItemProgress(item: visible, record: nil)])) {
            itemStore.completeRetrieval(with: [visible, hidden])
            recordStore.completeRetrievalAll(with: [])
        }
    }
    
    func test_load_deliversProgressWithMatchingRecord() {
        let (sut, itemStore, recordStore) = makeSUT()
        let date = Date()
        
        let item = uniqueItem(startDate: date)
        let record = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: date,
            currentCount: 3,
            isCompleted: false,
            timerStartDate: Date(),
            createdAt: date,
            updatedAt: date
        )
        
        expect(sut, for: date, toCompleteWith: .success([ItemProgress(item: item, record: record)])) {
            itemStore.completeRetrieval(with: [item])
            recordStore.completeRetrievalAll(with: [record])
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalDailyProgressLoader, itemStore: ItemStoreSpy, recordStore: DailyRecordStoreSpy) {
        let itemStore = ItemStoreSpy()
        let recordStore = DailyRecordStoreSpy()
        let sut = LocalDailyProgressLoader(itemStore: itemStore, dailyRecordStore: recordStore)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(itemStore, file: file, line: line)
        trackForMemoryLeaks(recordStore, file: file, line: line)
        return (sut, itemStore, recordStore)
    }
    
    private func expect(
        _ sut: LocalDailyProgressLoader,
        for date: Date,
        toCompleteWith expectedResult: DailyProgressLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load(for: date) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(received), .success(expected)):
                XCTAssertEqual(received, expected, file: file, line: line)
            case let (.failure(received as LocalDailyProgressLoader.Error), .failure(expected as LocalDailyProgressLoader.Error)):
                XCTAssertEqual(received, expected, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalDailyProgressLoader,
        toCompleteWith expectedResult: DailyProgressLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, for: Date(), toCompleteWith: expectedResult, when: action, file: file, line: line)
    }
}
