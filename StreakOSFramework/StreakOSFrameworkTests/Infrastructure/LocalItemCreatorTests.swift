import XCTest
@testable import StreakOSFramework

final class LocalItemCreatorTests: XCTestCase {
    
    private var today: Date { Date().startOfDay }
    
    func test_create_retrievesItemsThenSaves() {
        let (sut, itemStore) = makeSUT()
        let date = today
        
        sut.create(name: "Push Ups", icon: "💪", type: .count, targetCount: 10, startDate: date, endDate: nil) { _ in }
        
        XCTAssertEqual(itemStore.receivedMessages, [.retrieveAll])
    }
    
    func test_create_deliversErrorOnRetrievalFailure() {
        let (sut, itemStore) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalItemCreator.Error.retrievalFailed)) {
            itemStore.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_create_duplicateName_deliversErrorAndDoesNotSave() {
        let (sut, itemStore) = makeSUT()
        let date = today
        let existing = uniqueItem(name: "Walk", startDate: date)
        
        expect(sut, name: "Walk", icon: "🚶", toCompleteWith: .failure(LocalItemCreator.Error.duplicateName)) {
            itemStore.completeRetrieval(with: [existing])
        }
    }
    
    func test_create_duplicateName_isCaseInsensitive() {
        let (sut, itemStore) = makeSUT()
        let date = today
        let existing = uniqueItem(name: "Walk", startDate: date)
        
        expect(sut, name: "walk", icon: "🚶", toCompleteWith: .failure(LocalItemCreator.Error.duplicateName)) {
            itemStore.completeRetrieval(with: [existing])
        }
    }
    
    func test_create_uniqueName_deliversCreatedItem() {
        let (sut, itemStore) = makeSUT()
        let date = today
        
        let exp = expectation(description: "create")
        
        sut.create(name: "Push Ups", icon: "💪", type: .count, targetCount: 10, startDate: date, endDate: nil) { result in
            switch result {
            case let .success(item):
                XCTAssertEqual(item.name, "Push Ups")
                XCTAssertEqual(item.icon, "💪")
                XCTAssertEqual(item.targetCount, 10)
                XCTAssertEqual(item.startDate, date)
                XCTAssertNil(item.endDate)
            case .failure:
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_create_placesNewItemAtTop() {
        let (sut, itemStore) = makeSUT()
        let date = today
        let existing = uniqueItem(name: "Old", targetCount: 1, startDate: date)
        
        let exp = expectation(description: "create")
        
        sut.create(name: "New", icon: "📋", type: .count, targetCount: 1, startDate: date, endDate: nil) { result in
            if case let .success(item) = result {
                XCTAssertEqual(item.displayOrder, existing.displayOrder - 1)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [existing])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_create_usesProvidedEndDate() {
        let (sut, itemStore) = makeSUT()
        let date = today
        let end = date.adding(days: 7)
        
        let exp = expectation(description: "create")
        
        sut.create(name: "Push Ups", icon: "💪", type: .count, targetCount: 5, startDate: date, endDate: end) { result in
            if case let .success(item) = result {
                XCTAssertEqual(item.endDate, end)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        itemStore.completeRetrieval(with: [])
        itemStore.completeSaveSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_create_deliversErrorOnSaveFailure() {
        let (sut, itemStore) = makeSUT()
        _ = today
        
        expect(sut, toCompleteWith: .failure(LocalItemCreator.Error.saveFailed)) {
            itemStore.completeRetrieval(with: [])
            itemStore.completeSave(with: anyNSError())
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalItemCreator, itemStore: ItemStoreSpy) {
        let itemStore = ItemStoreSpy()
        let sut = LocalItemCreator(itemStore: itemStore, currentDate: { self.today })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(itemStore, file: file, line: line)
        return (sut, itemStore)
    }
    
    private func expect(
        _ sut: LocalItemCreator,
        name: String = "any name",
        icon: String = "📋",
        toCompleteWith expectedResult: ItemCreator.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for create completion")
        
        sut.create(name: name, icon: icon, type: .count, targetCount: 1, startDate: today, endDate: nil) { received in
            switch (received, expectedResult) {
            case let (.success(received), .success(expected)):
                XCTAssertEqual(received, expected, file: file, line: line)
            case let (.failure(received as LocalItemCreator.Error), .failure(expected as LocalItemCreator.Error)):
                XCTAssertEqual(received, expected, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(received)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
