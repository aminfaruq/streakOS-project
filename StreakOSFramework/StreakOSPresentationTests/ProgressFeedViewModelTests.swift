import XCTest
import StreakOSFramework
@testable import StreakOSPresentation

final class DailyProgressLoaderSpy: DailyProgressLoader {
    private(set) var receivedDates = [Date]()
    private var completions = [(DailyProgressLoader.Result) -> Void]()
    
    var requestedDates: [Date] { receivedDates }
    
    func load(for date: Date, completion: @escaping (DailyProgressLoader.Result) -> Void) {
        receivedDates.append(date)
        completions.append(completion)
    }
    
    func complete(with items: [ItemProgress], at index: Int = 0) {
        completions[index](.success(items))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}

final class ProgressTrackerSpy: ProgressTracker {
    private(set) var receivedMessages = [Message]()
    
    enum Message: Equatable {
        case increment(Item, Date)
        case decrement(Item, Date)
    }
    
    private var incrementCompletions = [(ProgressTracker.Result) -> Void]()
    private var decrementCompletions = [(ProgressTracker.Result) -> Void]()
    
    func increment(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        receivedMessages.append(.increment(item, date))
        incrementCompletions.append(completion)
    }
    
    func decrement(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        receivedMessages.append(.decrement(item, date))
        decrementCompletions.append(completion)
    }
    
    func completeIncrement(with record: DailyRecord, at index: Int = 0) {
        incrementCompletions[index](.success(record))
    }
    
    func completeDecrement(with record: DailyRecord, at index: Int = 0) {
        decrementCompletions[index](.success(record))
    }
}

@MainActor
final class ProgressFeedViewModelTests: XCTestCase {
    
    func test_init_doesNotLoad() {
        let (sut, loader) = makeSUT()
        
        XCTAssertTrue(loader.requestedDates.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.progressItems.isEmpty)
    }
    
    func test_load_setsIsLoadingBeforeCompletion() async {
        let (sut, loader) = makeSUT()
        
        sut.load(for: anyDate)
        await Task.yield()
        XCTAssertTrue(sut.isLoading)
        
        loader.complete(with: makeProgressItems())
        await Task.yield()
    }
    
    func test_load_requestsDateFromLoader() async {
        let (sut, loader) = makeSUT()
        let date = Date()
        
        sut.load(for: date)
        await Task.yield()
        
        XCTAssertEqual(loader.requestedDates, [date])
        
        loader.complete(with: makeProgressItems())
        await Task.yield()
    }
    
    func test_load_deliversItemsOnSuccess() async {
        let (sut, loader) = makeSUT()
        let expected = makeProgressItems()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: expected)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems, expected)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_load_clearsErrorMessageOnSuccess() async {
        let (sut, loader) = makeSUT()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: anyNSError(), at: 0)
        await Task.yield()
        XCTAssertNotNil(sut.errorMessage)
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: makeProgressItems(), at: 1)
        await Task.yield()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_load_deliversErrorMessageOnFailure() async {
        let (sut, loader) = makeSUT()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: anyNSError())
        await Task.yield()
        
        XCTAssertTrue(sut.progressItems.isEmpty)
        XCTAssertEqual(sut.errorMessage, "Failed to load progress")
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_load_clearsIsLoadingAfterCompletion() async {
        let (sut, loader) = makeSUT()
        
        sut.load(for: anyDate)
        await Task.yield()
        XCTAssertTrue(sut.isLoading)
        
        loader.complete(with: makeProgressItems())
        await Task.yield()
        
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_cancel_doesNotDeliverResult() async {
        let (sut, loader) = makeSUT()
        
        sut.load(for: anyDate)
        await Task.yield()
        XCTAssertTrue(sut.isLoading)
        
        sut.cancel()
        loader.complete(with: makeProgressItems())
        await Task.yield()
        
        XCTAssertTrue(sut.progressItems.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: Increment
    
    func test_increment_requestsTrackerIncrement() async {
        let (sut, _, tracker) = makeSUTWithTracker()
        let progress = makeProgressItems()[0]
        let date = anyDate
        
        sut.increment(progress, on: date)
        await Task.yield()
        
        XCTAssertEqual(tracker.receivedMessages, [.increment(progress.item, date)])
    }
    
    func test_increment_replacesProgressWithUpdatedRecord() async {
        let (sut, loader, tracker) = makeSUTWithTracker()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: makeProgressItems())
        await Task.yield()
        
        let progress = sut.progressItems[0]
        let updatedRecord = DailyRecord.new(for: progress.item.id, on: anyDate).incrementing(targetCount: progress.item.targetCount)
        
        sut.increment(progress, on: anyDate)
        await Task.yield()
        tracker.completeIncrement(with: updatedRecord)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems, [ItemProgress(item: progress.item, record: updatedRecord)])
    }
    
    // MARK: Decrement
    
    func test_decrement_requestsTrackerDecrement() async {
        let (sut, _, tracker) = makeSUTWithTracker()
        let progress = makeProgressItems()[0]
        let date = anyDate
        
        sut.decrement(progress, on: date)
        await Task.yield()
        
        XCTAssertEqual(tracker.receivedMessages, [.decrement(progress.item, date)])
    }
    
    func test_decrement_replacesProgressWithUpdatedRecord() async {
        let (sut, loader, tracker) = makeSUTWithTracker()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: makeProgressItems())
        await Task.yield()
        
        let progress = sut.progressItems[0]
        let updatedRecord = DailyRecord.new(for: progress.item.id, on: anyDate).decrementing(targetCount: progress.item.targetCount)
        
        sut.decrement(progress, on: anyDate)
        await Task.yield()
        tracker.completeDecrement(with: updatedRecord)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems, [ItemProgress(item: progress.item, record: updatedRecord)])
    }
    
    // MARK: Helpers
    
    private var anyDate: Date { Date(timeIntervalSince1970: 1_700_000_000) }
    
    private func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy) {
        let loader = DailyProgressLoaderSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: nil)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeSUTWithTracker(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy, tracker: ProgressTrackerSpy) {
        let loader = DailyProgressLoaderSpy()
        let tracker = ProgressTrackerSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: tracker)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(tracker, file: file, line: line)
        return (sut, loader, tracker)
    }
    
    private func makeProgressItems() -> [ItemProgress] {
        let item = Item(
            id: UUID(),
            name: "Push Ups",
            icon: "💪",
            targetCount: 10,
            startDate: anyDate,
            endDate: nil,
            displayOrder: 0,
            createdAt: anyDate,
            updatedAt: anyDate
        )
        return [ItemProgress(item: item, record: nil)]
    }
}
