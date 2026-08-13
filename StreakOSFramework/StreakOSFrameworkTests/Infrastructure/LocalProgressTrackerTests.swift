import XCTest
@testable import StreakOSFramework

final class LocalProgressTrackerTests: XCTestCase {
    
    private var today: Date { Date().startOfDay }
    
    // MARK: increment
    
    func test_increment_retrievesRecordThenSaves() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        
        expect(sut, item: item, on: date, actionType: .increment) {
            store.completeRetrieval(with: nil)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 1)
            XCTAssertFalse(saved.isCompleted)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_increment_minutesType_addsSixtySecondsAndUsesCorrectThreshold() {
        let (sut, store) = makeSUT()
        let item = Item(
            id: UUID(), name: "Read", icon: "📚", type: .minutes, targetCount: 15,
            startDate: today, endDate: nil, displayOrder: 0,
            createdAt: today, updatedAt: today
        )
        
        expect(sut, item: item, on: today, actionType: .increment) {
            store.completeRetrieval(with: .none)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 60) // +1 minute
            XCTAssertFalse(saved.isCompleted) // 60 < 15 * 60
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_increment_usesExistingRecordOnRetrieval() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        let existing = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: date,
            currentCount: 1,
            isCompleted: false,
            timerStartDate: Date(),
            createdAt: date,
            updatedAt: date
        )
        
        expect(sut, item: item, on: date, actionType: .increment) {
            store.completeRetrieval(with: existing)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 2)
            XCTAssertFalse(saved.isCompleted)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_increment_deliversUpdatedRecordOnSuccess() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        
        let exp = expectation(description: "Wait for tracker completion")
        var delivered: DailyRecord?
        
        sut.increment(item, on: date) { result in
            if case let .success(record) = result {
                delivered = record
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: nil)
        store.completeSaveSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(delivered)
        XCTAssertEqual(delivered?.itemId, item.id)
        XCTAssertEqual(delivered?.currentCount, 1)
        XCTAssertFalse(delivered?.isCompleted ?? true)
    }
    
    func test_increment_deliversErrorOnRetrievalFailure() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        
        expect(sut, item: item, on: today, actionType: .increment, toDeliver: .failure(LocalProgressTracker.Error.retrievalFailed)) {
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_increment_deliversErrorOnSaveFailure() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        
        expect(sut, item: item, on: today, actionType: .increment, toDeliver: .failure(LocalProgressTracker.Error.saveFailed)) {
            store.completeRetrieval(with: nil)
            store.completeSave(with: anyNSError())
        }
    }
    
    func test_increment_readOnlyDate_doesNotRetrieveOrSave() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let tomorrow = today.adding(days: 1)
        
        expect(sut, item: item, on: tomorrow, actionType: .increment, toDeliver: .failure(LocalProgressTracker.Error.dateNotEditable)) {}
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_increment_inaccessibleDate_doesNotRetrieveOrSave() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let farFuture = today.adding(days: 10)
        
        expect(sut, item: item, on: farFuture, actionType: .increment, toDeliver: .failure(LocalProgressTracker.Error.dateNotEditable)) {}
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: decrement
    
    func test_decrement_retrievesRecordThenSaves() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        
        expect(sut, item: item, on: date, actionType: .decrement) {
            store.completeRetrieval(with: nil)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 0)
            XCTAssertFalse(saved.isCompleted)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_decrement_fromCompleted_recordGoesToTargetMinusOne() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today, targetCount: 5)
        let date = today
        let completed = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: date,
            currentCount: 5,
            isCompleted: true,
            timerStartDate: Date(),
            createdAt: date,
            updatedAt: date
        )
        
        expect(sut, item: item, on: date, actionType: .decrement) {
            store.completeRetrieval(with: completed)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 4)
            XCTAssertFalse(saved.isCompleted)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_decrement_deliversErrorOnRetrievalFailure() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        
        expect(sut, item: item, on: today, actionType: .decrement, toDeliver: .failure(LocalProgressTracker.Error.retrievalFailed)) {
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_decrement_readOnlyDate_doesNotRetrieveOrSave() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let tomorrow = today.adding(days: 1)
        
        expect(sut, item: item, on: tomorrow, actionType: .decrement, toDeliver: .failure(LocalProgressTracker.Error.dateNotEditable)) {}
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: toggleTimer
    
    func test_toggleTimer_retrievesRecordThenSaves() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        
        expect(sut, item: item, on: date, actionType: .toggleTimer) {
            store.completeRetrieval(with: nil)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertNotNil(saved.timerStartDate)
            XCTAssertFalse(saved.isCompleted)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_toggleTimer_deliversErrorOnRetrievalFailure() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        
        expect(sut, item: item, on: today, actionType: .toggleTimer, toDeliver: .failure(LocalProgressTracker.Error.retrievalFailed)) {
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_toggleTimer_readOnlyDate_doesNotRetrieveOrSave() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let tomorrow = today.adding(days: 1)
        
        expect(sut, item: item, on: tomorrow, actionType: .toggleTimer, toDeliver: .failure(LocalProgressTracker.Error.dateNotEditable)) {}
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: restart
    
    func test_restart_retrievesRecordThenSaves() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let date = today
        let existing = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: date,
            currentCount: 5,
            isCompleted: true,
            timerStartDate: Date(),
            createdAt: date,
            updatedAt: date
        )
        
        expect(sut, item: item, on: date, actionType: .restart) {
            store.completeRetrieval(with: existing)
            store.completeSaveSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages.count, 2)
        if case let .save(saved)? = store.receivedMessages.last {
            XCTAssertEqual(saved.itemId, item.id)
            XCTAssertEqual(saved.currentCount, 0)
            XCTAssertFalse(saved.isCompleted)
            XCTAssertNil(saved.timerStartDate)
        } else {
            XCTFail("Expected a save message")
        }
    }
    
    func test_restart_deliversErrorOnRetrievalFailure() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        
        expect(sut, item: item, on: today, actionType: .restart, toDeliver: .failure(LocalProgressTracker.Error.retrievalFailed)) {
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_restart_readOnlyDate_doesNotRetrieveOrSave() {
        let (sut, store) = makeSUT()
        let item = uniqueItem(date: today)
        let tomorrow = today.adding(days: 1)
        
        expect(sut, item: item, on: tomorrow, actionType: .restart, toDeliver: .failure(LocalProgressTracker.Error.dateNotEditable)) {}
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalProgressTracker, store: DailyRecordStoreSpy) {
        let store = DailyRecordStoreSpy()
        let sut = LocalProgressTracker(store: store, currentDate: { self.today })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem(date: Date, targetCount: Int = 3) -> Item {
        Item(
            id: UUID(),
            name: "any name",
            icon: "📋",
            type: ItemType.count,
            targetCount: targetCount,
            startDate: date,
            endDate: nil,
            displayOrder: 0,
            createdAt: date,
            updatedAt: date
        )
    }
    
    private func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }
    
    enum ActionType { case increment, decrement, toggleTimer, restart }
    
    private func expect(
        _ sut: LocalProgressTracker,
        item: Item,
        on date: Date,
        actionType: ActionType,
        toDeliver expectedResult: ProgressTracker.Result? = nil,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for tracker completion")
        
        let completion: (ProgressTracker.Result) -> Void = { received in
            if let expectedResult {
                switch (received, expectedResult) {
                case let (.success(received), .success(expected)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                case let (.failure(received as LocalProgressTracker.Error), .failure(expected as LocalProgressTracker.Error)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult) got \(received)", file: file, line: line)
                }
            }
            exp.fulfill()
        }
        
        switch actionType {
        case .increment:
            sut.increment(item, on: date, completion: completion)
        case .decrement:
            sut.decrement(item, on: date, completion: completion)
        case .toggleTimer:
            sut.toggleTimer(item, on: date, completion: completion)
        case .restart:
            sut.restart(item, on: date, completion: completion)
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
