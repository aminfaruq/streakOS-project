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

    // MARK: Helpers

    private var anyDate: Date { Date(timeIntervalSince1970: 1_700_000_000) }

    private func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProgressFeedViewModel, loader: DailyProgressLoaderSpy) {
        let loader = DailyProgressLoaderSpy()
        let sut = ProgressFeedViewModel(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
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