import XCTest
@testable import StreakOSFramework

final class LocalItemUpdaterTests: XCTestCase {
    
    private var today: Date { Date().startOfDay }
    
    func test_update_retrievesItemsThenSaves() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item) {
            itemStore.completeRetrieval(with: [item])
            itemStore.completeSaveSuccessfully()
        }
        
        XCTAssertTrue(itemStore.receivedMessages.contains(.retrieveAll))
    }
    
    func test_update_deliversErrorOnRetrievalFailure() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item, toCompleteWith: .retrievalFailed) {
            itemStore.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_update_notFound_deliversError() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(startDate: today)
        
        expect(sut, item: item, toCompleteWith: .notFound) {
            itemStore.completeRetrieval(with: [])
        }
    }
    
    func test_update_duplicateName_deliversErrorAndDoesNotSave() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(name: "Walk", startDate: today)
        let other = uniqueItem(name: "Walk", startDate: today)
        
        expect(sut, item: item, toCompleteWith: .duplicateName) {
            itemStore.completeRetrieval(with: [item, other])
        }
    }
    
    func test_update_sameNameAsSelf_allowed() {
        let (sut, itemStore) = makeSUT()
        let item = uniqueItem(name: "Walk", startDate: today)
        
        expect(sut, item: item) {
            itemStore.completeRetrieval(with: [item])
            itemStore.completeSaveSuccessfully()
        }
    }
    
    func test_update_deliversUpdatedItemOnSuccess() {
        let (sut, itemStore) = makeSUT()
        let date = today
        let existing = uniqueItem(name: "Old", startDate: date)
        let changed = Item(
            id: existing.id,
            name: "New Name",
            icon: existing.icon,
            targetCount: 7,
            startDate: existing.startDate,
            endDate: nil,
            displayOrder: existing.displayOrder,
            createdAt: existing.createdAt,
            updatedAt: existing.updatedAt
        )
        
        let exp = expectation(description: "update")
        sut.update(changed) { result in
            if case let .success(item) = result {
                XCTAssertEqual(item.id, existing.id)
                XCTAssertEqual(item.name, "New Name")
                XCTAssertEqual(item.targetCount, 7)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [existing])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_update_deliversErrorOnSaveFailure() {
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
    ) -> (sut: LocalItemUpdater, itemStore: ItemStoreSpy) {
        let itemStore = ItemStoreSpy()
        let sut = LocalItemUpdater(itemStore: itemStore, currentDate: { self.today })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(itemStore, file: file, line: line)
        return (sut, itemStore)
    }
    
    private func expect(
        _ sut: LocalItemUpdater,
        item: Item,
        toCompleteWith expectedError: LocalItemUpdater.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, item: item, expectedResult: ItemUpdater.Result.failure(expectedError), when: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: LocalItemUpdater,
        item: Item,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, item: item, expectedResult: nil, when: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: LocalItemUpdater,
        item: Item,
        expectedResult: ItemUpdater.Result?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for update completion")
        
        sut.update(item) { received in
            if let expectedResult {
                switch (received, expectedResult) {
                case let (.success(received), .success(expected)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                case let (.failure(received as LocalItemUpdater.Error), .failure(expected as LocalItemUpdater.Error)):
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
