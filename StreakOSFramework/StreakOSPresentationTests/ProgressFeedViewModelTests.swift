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
        case toggleTimer(Item, Date)
    }
    
    private var incrementCompletions = [(ProgressTracker.Result) -> Void]()
    private var decrementCompletions = [(ProgressTracker.Result) -> Void]()
    private var toggleTimerCompletions = [(ProgressTracker.Result) -> Void]()
    
    func increment(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        receivedMessages.append(.increment(item, date))
        incrementCompletions.append(completion)
    }
    
    func decrement(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        receivedMessages.append(.decrement(item, date))
        decrementCompletions.append(completion)
    }
    
    func toggleTimer(_ item: Item, on date: Date, completion: @escaping (ProgressTracker.Result) -> Void) {
        receivedMessages.append(.toggleTimer(item, date))
        toggleTimerCompletions.append(completion)
    }
    
    func completeIncrement(with record: DailyRecord, at index: Int = 0) {
        incrementCompletions[index](.success(record))
    }
    
    func completeDecrement(with record: DailyRecord, at index: Int = 0) {
        decrementCompletions[index](.success(record))
    }
    
    func completeToggleTimer(with record: DailyRecord, at index: Int = 0) {
        toggleTimerCompletions[index](.success(record))
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
    
    // MARK: Toggle Timer
    
    func test_toggleTimer_requestsTrackerToggleTimer() async {
        let (sut, _, tracker) = makeSUTWithTracker()
        let progress = makeProgressItems()[0]
        let date = anyDate
        
        sut.toggleTimer(for: progress, on: date)
        await Task.yield()
        
        XCTAssertEqual(tracker.receivedMessages, [.toggleTimer(progress.item, date)])
    }
    
    func test_toggleTimer_replacesProgressWithUpdatedRecord() async {
        let (sut, loader, tracker) = makeSUTWithTracker()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: makeProgressItems())
        await Task.yield()
        
        let progress = sut.progressItems[0]
        let updatedRecord = DailyRecord.new(for: progress.item.id, on: anyDate).togglingTimer(targetCount: progress.item.targetCount)
        
        sut.toggleTimer(for: progress, on: anyDate)
        await Task.yield()
        tracker.completeToggleTimer(with: updatedRecord)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems, [ItemProgress(item: progress.item, record: updatedRecord)])
    }
    
    // MARK: Delete
    
    func test_delete_requestsStoreDeletion() async {
        let (sut, _, itemStore) = makeSUTWithStore()
        let progress = makeProgressItems()[0]
        
        sut.delete(progress)
        await Task.yield()
        
        XCTAssertEqual(itemStore.receivedMessages, [.delete(progress.item)])
    }
    
    func test_delete_removesItemFromListOnSuccess() async {
        let (sut, loader, itemStore) = makeSUTWithStore()
        let loaded = makeProgressItems()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: loaded)
        await waitUntilLoaded(sut, equals: loaded)
        
        let progress = loaded[0]
        sut.delete(progress)
        await Task.yield()
        itemStore.completeDeleteSuccessfully()
        await Task.yield()
        
        XCTAssertTrue(sut.progressItems.isEmpty)
    }
    
    func test_delete_deliversErrorMessageOnFailure() async {
        let (sut, loader, itemStore) = makeSUTWithStore()
        let loaded = makeProgressItems()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: loaded)
        await waitUntilLoaded(sut, equals: loaded)
        
        let progress = loaded[0]
        sut.delete(progress)
        await Task.yield()
        itemStore.completeDelete(with: anyNSError())
        await Task.yield()
        
        XCTAssertEqual(sut.errorMessage, "Failed to delete item")
        XCTAssertEqual(sut.progressItems.count, 1)
    }
    
    // MARK: Duplicate
    
    func test_duplicate_requestsDuplicator() async {
        let (sut, _, duplicator) = makeSUTWithDuplicator()
        let progress = makeProgressItems()[0]
        
        sut.duplicate(progress, on: anyDate)
        await Task.yield()
        
        XCTAssertEqual(duplicator.receivedMessages, [.duplicate(progress.item)])
    }
    
    func test_duplicate_deliversErrorMessageOnFailure() async {
        let (sut, _, duplicator) = makeSUTWithDuplicator()
        let progress = makeProgressItems()[0]
        
        sut.duplicate(progress, on: anyDate)
        await Task.yield()
        duplicator.completeDuplicate(with: anyNSError())
        await Task.yield()
        
        XCTAssertEqual(sut.errorMessage, "Failed to duplicate item")
    }
    
    func test_duplicate_reloadsDataOnSuccess() async {
        let (sut, loader, duplicator) = makeSUTWithDuplicator()
        let progress = makeProgressItems()[0]
        
        sut.duplicate(progress, on: anyDate)
        await Task.yield()
        duplicator.completeDuplicateSuccessfully(with: progress.item)
        await Task.yield()
        
        await waitUntilLoaderCount(loader, equals: 1)
        XCTAssertEqual(loader.requestedDates, [anyDate])
        
        loader.complete(with: makeProgressItems())
        await Task.yield()
    }
    
    // MARK: Update
    
    func test_update_requestsUpdater() async {
        let (sut, _, updater) = makeSUTWithUpdater()
        let progress = makeProgressItems()[0]
        let updatedItem = progress.item
        
        sut.update(progress, with: updatedItem, on: anyDate)
        await Task.yield()
        
        XCTAssertEqual(updater.receivedMessages.map { $0.item }, [updatedItem])
    }
    
    func test_update_deliversErrorMessageOnFailure() async {
        let (sut, _, updater) = makeSUTWithUpdater()
        let progress = makeProgressItems()[0]
        
        sut.update(progress, with: progress.item, on: anyDate)
        await Task.yield()
        updater.completeUpdate(with: anyNSError())
        await Task.yield()
        
        XCTAssertEqual(sut.errorMessage, "Failed to update item")
    }
    
    func test_update_reloadsDataOnSuccess() async {
        let (sut, loader, updater) = makeSUTWithUpdater()
        let progress = makeProgressItems()[0]
        
        sut.update(progress, with: progress.item, on: anyDate)
        await Task.yield()
        updater.completeUpdateSuccessfully(with: progress.item)
        await Task.yield()
        
        await waitUntilLoaderCount(loader, equals: 1)
        XCTAssertEqual(loader.requestedDates, [anyDate])
        
        loader.complete(with: makeProgressItems())
        await Task.yield()
    }
    
    // MARK: Reorder
    
    func test_reorder_doesNotMutateOnInvalidIndices() async {
        let (sut, loader, updater) = makeSUTWithUpdater()
        let loaded = makeProgressItems()
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: loaded)
        await waitUntilLoaded(sut, equals: loaded)
        
        sut.reorder(from: -1, to: 0)
        sut.reorder(from: 0, to: 5)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems, loaded)
        XCTAssertTrue(updater.receivedMessages.isEmpty)
    }
    
    func test_reorder_updatesProgressItemsOrderLocally() async {
        let (sut, loader, updater) = makeSUTWithUpdater()
        let items = [
            makeProgressItem(name: "Item 1", displayOrder: 0),
            makeProgressItem(name: "Item 2", displayOrder: 1),
            makeProgressItem(name: "Item 3", displayOrder: 2)
        ]
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: items)
        await waitUntilLoaded(sut, equals: items)
        
        sut.reorder(from: 0, to: 2)
        await Task.yield()
        
        XCTAssertEqual(sut.progressItems.map { $0.item.name }, ["Item 2", "Item 3", "Item 1"])
        XCTAssertEqual(sut.progressItems.map { $0.item.displayOrder }, [0, 1, 2])
        
        // Complete hanging updates sequentially to prevent memory leaks in test
        await waitUntilUpdaterCount(updater, equals: 1)
        updater.completeUpdateSuccessfully(with: items[0].item, at: 0)
        
        await waitUntilUpdaterCount(updater, equals: 2)
        updater.completeUpdateSuccessfully(with: items[1].item, at: 1)
        
        await waitUntilUpdaterCount(updater, equals: 3)
        updater.completeUpdateSuccessfully(with: items[2].item, at: 2)
        
        await waitUntilLoaderCount(loader, equals: 2)
        loader.complete(with: items, at: 1)
        await Task.yield()
    }
    
    func test_reorder_requestsUpdaterForReorderedItemsSequentially() async {
        let (sut, loader, updater) = makeSUTWithUpdater()
        let items = [
            makeProgressItem(name: "Item 1", displayOrder: 0),
            makeProgressItem(name: "Item 2", displayOrder: 1)
        ]
        
        sut.load(for: anyDate)
        await Task.yield()
        loader.complete(with: items, at: 0)
        await waitUntilLoaded(sut, equals: items)
        
        sut.reorder(from: 0, to: 1)
        await Task.yield()
        
        // Optimistic UI update
        XCTAssertEqual(sut.progressItems.map { $0.item.name }, ["Item 2", "Item 1"])
        
        // 1st update
        await waitUntilUpdaterCount(updater, equals: 1)
        XCTAssertEqual(updater.receivedMessages.count, 1)
        updater.completeUpdateSuccessfully(with: updater.receivedMessages.last!.item, at: 0)
        
        // 2nd update
        await waitUntilUpdaterCount(updater, equals: 2)
        XCTAssertEqual(updater.receivedMessages.count, 2)
        updater.completeUpdateSuccessfully(with: updater.receivedMessages.last!.item, at: 1)
        
        // Reload triggered after updates complete
        await waitUntilLoaderCount(loader, equals: 2)
        XCTAssertEqual(loader.requestedDates.count, 2)
        loader.complete(with: items, at: 1)
        await Task.yield()
    }
    
    func test_updateItemsLocally_replacesProgressItems() async {
        let (sut, _, _) = makeSUTWithUpdater()
        let items = [makeProgressItem(name: "Local", displayOrder: 0)]
        
        sut.updateItemsLocally(items)
        
        XCTAssertEqual(sut.progressItems, items)
    }
    
    // MARK: Helpers
    
    private var anyDate: Date { Date(timeIntervalSince1970: 1_700_000_000) }
    
    private func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }
    
    private func waitUntilLoaded(_ sut: ProgressFeedViewModel, equals expected: [ItemProgress]? = nil) async {
        for _ in 0..<100 {
            if expected == nil ? !sut.isLoading && !sut.progressItems.isEmpty : sut.progressItems == expected {
                return
            }
            await Task.yield()
        }
    }
    
    private func waitUntilUpdaterCount(_ updater: ItemUpdaterSpy, equals count: Int) async {
        for _ in 0..<100 {
            if updater.receivedMessages.count == count { return }
            await Task.yield()
        }
    }
    
    private func waitUntilLoaderCount(_ loader: DailyProgressLoaderSpy, equals count: Int) async {
        for _ in 0..<100 {
            if loader.requestedDates.count == count { return }
            await Task.yield()
        }
    }
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy) {
        let loader = DailyProgressLoaderSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: nil, itemStore: nil)
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
        let sut = ProgressFeedViewModel(loader: loader, tracker: tracker, itemStore: nil)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(tracker, file: file, line: line)
        return (sut, loader, tracker)
    }
    
    private func makeSUTWithStore(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy, itemStore: ItemStoreSpy) {
        let loader = DailyProgressLoaderSpy()
        let itemStore = ItemStoreSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: nil, itemStore: itemStore)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(itemStore, file: file, line: line)
        return (sut, loader, itemStore)
    }
    
    private func makeSUTWithUpdater(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy, updater: ItemUpdaterSpy) {
        let loader = DailyProgressLoaderSpy()
        let updater = ItemUpdaterSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: nil, itemStore: nil, updater: updater)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(updater, file: file, line: line)
        return (sut, loader, updater)
    }
    
    private func makeSUTWithDuplicator(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy, duplicator: ItemDuplicatorSpy) {
        let loader = DailyProgressLoaderSpy()
        let duplicator = ItemDuplicatorSpy()
        let sut = ProgressFeedViewModel(loader: loader, tracker: nil, itemStore: nil, updater: nil, duplicator: duplicator)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(duplicator, file: file, line: line)
        return (sut, loader, duplicator)
    }
    
    private func makeProgressItems() -> [ItemProgress] {
        return [makeProgressItem(name: "Push Ups", displayOrder: 0)]
    }
    
    private func makeProgressItem(name: String, displayOrder: Int) -> ItemProgress {
        let item = Item(
            id: UUID(),
            name: name,
            icon: "💪",
            type: .count,
            targetCount: 10,
            startDate: anyDate,
            endDate: nil,
            displayOrder: displayOrder,
            createdAt: anyDate,
            updatedAt: anyDate
        )
        return ItemProgress(item: item, record: nil)
    }
}
