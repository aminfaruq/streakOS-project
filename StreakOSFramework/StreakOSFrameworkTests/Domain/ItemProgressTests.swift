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
            timerStartDate: Date(),
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
            timerStartDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)
        
        XCTAssertEqual(sut.progressFraction, 1.0)
    }
    
    func test_progressFraction_minutesType_returnsCorrectFraction() {
        let item = Item(
            id: UUID(), name: "Read", icon: "📚", type: .minutes, targetCount: 15,
            startDate: Date(), endDate: nil, displayOrder: 0,
            createdAt: Date(), updatedAt: Date()
        )
        let record = DailyRecord(
            id: UUID(), itemId: item.id, date: Date(),
            currentCount: 450, // 450 seconds = 7.5 minutes
            isCompleted: false, timerStartDate: nil,
            createdAt: Date(), updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)
        
        XCTAssertEqual(sut.progressFraction, 0.5) // 450 / 900
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
            timerStartDate: Date(),
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
            timerStartDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)
        
        XCTAssertEqual(sut.displayText, "✓")
    }
    
    func test_displayText_minutesType_showsMinutesCorrectly() {
        let item = Item(
            id: UUID(), name: "Read", icon: "📚", type: .minutes, targetCount: 15,
            startDate: Date(), endDate: nil, displayOrder: 0,
            createdAt: Date(), updatedAt: Date()
        )
        let record = DailyRecord(
            id: UUID(), itemId: item.id, date: Date(),
            currentCount: 120, // 2 minutes
            isCompleted: false, timerStartDate: nil,
            createdAt: Date(), updatedAt: Date()
        )
        let sut = ItemProgress(item: item, record: record)
        
        XCTAssertEqual(sut.displayText, "2/15")
    }
}
