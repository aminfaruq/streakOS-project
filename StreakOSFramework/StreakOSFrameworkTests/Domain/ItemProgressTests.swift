import XCTest
@testable import StreakOSFramework

final class ItemProgressTests: XCTestCase {

    func test_progressFraction_noRecord_returnsZero() {
        let item = uniqueItem(targetCount: 5)
        let sut = ItemProgress(item: item, record: nil)

        XCTAssertEqual(sut.progressFraction, 0)
    }

    func test_progressFraction_partial_returnsCorrectFraction() {
        let item = uniqueItem(targetCount: 4)
        let record = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: Date(),
            currentCount: 2,
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)

        XCTAssertEqual(sut.progressFraction, 0.5)
    }

    func test_progressFraction_completed_returnsOne() {
        let item = uniqueItem(targetCount: 10)
        let record = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: Date(),
            currentCount: 10,
            isCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)

        XCTAssertEqual(sut.progressFraction, 1.0)
    }

    func test_displayText_noRecord_showsZero() {
        let item = uniqueItem(targetCount: 5)
        let sut = ItemProgress(item: item, record: nil)

        XCTAssertEqual(sut.displayText, "0/5")
    }

    func test_displayText_partial_showsFraction() {
        let item = uniqueItem(targetCount: 5)
        let record = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: Date(),
            currentCount: 3,
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)

        XCTAssertEqual(sut.displayText, "3/5")
    }

    func test_displayText_completed_showsCheckmark() {
        let item = uniqueItem(targetCount: 5)
        let record = DailyRecord(
            id: UUID(),
            itemId: item.id,
            date: Date(),
            currentCount: 5,
            isCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)

        XCTAssertEqual(sut.displayText, "✓")
    }
}
