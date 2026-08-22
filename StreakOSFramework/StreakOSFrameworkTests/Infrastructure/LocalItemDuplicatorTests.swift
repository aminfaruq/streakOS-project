import XCTest
@testable import StreakOSFramework

final class LocalItemDuplicatorTests: XCTestCase {
    
    private var today: Date { Date().startOfDay }
    
    func test_duplicate_retrievesItemsThenSaves() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item) {
            itemStore.completeRetrieval(with: [item])
            itemStore.completeSaveSuccessfully()
        }
    }
    
    func test_duplicate_deliversErrorOnRetrievalFailure() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item, toCompleteWith: .retrievalFailed) {
            itemStore.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_duplicate_generatesUniqueNameAndPlacesOnTop() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(name: "Push Ups", startDate: today)
        
        let exp = expectation(description: "duplicate")
        sut.duplicate(item) { result in
            if case let .success(duplicate) = result {
                XCTAssertEqual(duplicate.name, "Push Ups 2")
                XCTAssertEqual(duplicate.icon, item.icon)
                XCTAssertEqual(duplicate.targetCount, item.targetCount)
                XCTAssertNotEqual(duplicate.id, item.id)
                XCTAssertEqual(duplicate.displayOrder, item.displayOrder - 1)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [item])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_duplicate_startsToday() {
        let (sut, itemStore) = makeSUT()
        let oldStart = today.adding(days: -30)
        let item = uniqueItem(startDate: oldStart)
        
        let exp = expectation(description: "duplicate")
        sut.duplicate(item) { result in
            if case let .success(duplicate) = result {
                XCTAssertEqual(Calendar.current.startOfDay(for: duplicate.startDate), self.today)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [item])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_duplicate_withTakenNumber_incrementsCounter() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(name: "Push Ups", startDate: today)
        let taken = uniqueItem(name: "Push Ups 2", startDate: today)
        
        let exp = expectation(description: "duplicate")
        sut.duplicate(item) { result in
            if case let .success(duplicate) = result {
                XCTAssertEqual(duplicate.name, "Push Ups 3")
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [item, taken])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_duplicate_copiesEndDate() {
        let (sut, itemStore) = makeSUT()
        let end = today.adding(days: 7)
        let item = uniqueItem(startDate: today, endDate: end)
        
        let exp = expectation(description: "duplicate")
        sut.duplicate(item) { result in
            if case let .success(duplicate) = result {
                XCTAssertEqual(duplicate.endDate, end)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [item])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_duplicate_copiesRepeatSchedule() {
        let (sut, itemStore) = makeSUT()
        let schedule = RepeatSchedule.weekdays
        let item = uniqueItem(startDate: today, repeatSchedule: schedule)
        
        let exp = expectation(description: "duplicate")
        sut.duplicate(item) { result in
            if case let .success(duplicate) = result {
                XCTAssertEqual(duplicate.repeatSchedule, schedule)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [item])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_duplicate_deliversErrorOnSaveFailure() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item, toCompleteWith: .saveFailed) {
            itemStore.completeRetrieval(with: [item])
            itemStore.completeSave(with: anyNSError())
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalItemDuplicator, itemStore: ItemStoreSpy) {
        let itemStore = ItemStoreSpy()
        let sut = LocalItemDuplicator(itemStore: itemStore, currentDate: { self.today })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(itemStore, file: file, line: line)
        return (sut, itemStore)
    }
    
    private func expect(
        _ sut: LocalItemDuplicator,
        item: Item,
        toCompleteWith expectedError: LocalItemDuplicator.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, item: item, expectedResult: ItemDuplicator.Result.failure(expectedError), when: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: LocalItemDuplicator,
        item: Item,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, item: item, expectedResult: nil, when: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: LocalItemDuplicator,
        item: Item,
        expectedResult: ItemDuplicator.Result?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for duplicate completion")
        
        sut.duplicate(item) { received in
            if let expectedResult {
                switch (received, expectedResult) {
                case let (.success(received), .success(expected)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                case let (.failure(received as LocalItemDuplicator.Error), .failure(expected as LocalItemDuplicator.Error)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult) got \(received)", file: file, line: line)
                }
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
