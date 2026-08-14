import XCTest
@testable import StreakOSFramework

final class DailyRecordTests: XCTestCase {
    
    func test_new_setsDefaults() {
        let itemId = UUID()
        let date = Date().startOfDay
        
        let sut = DailyRecord.new(for: itemId, on: date)
        
        XCTAssertEqual(sut.itemId, itemId)
        XCTAssertEqual(sut.currentCount, 0)
        XCTAssertFalse(sut.isCompleted)
        XCTAssertEqual(Calendar.current.startOfDay(for: sut.date), date)
    }
    
    func test_incrementing_fromZero_increasesCount() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        let result = sut.incrementing(targetCount: 5)
        
        XCTAssertEqual(result.currentCount, 1)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_incrementing_reachesTarget_completes() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        var record = sut
        record = record.incrementing(targetCount: 1)
        
        XCTAssertTrue(record.isCompleted)
        XCTAssertEqual(record.currentCount, 1)
    }
    
    func test_incrementing_whenCompleted_noChange() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.incrementing(targetCount: 1)
        
        let result = sut.incrementing(targetCount: 1)
        
        XCTAssertTrue(result.isCompleted)
        XCTAssertEqual(result.currentCount, 1)
    }
    
    func test_incrementing_multipleSteps() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        var record = sut
        record = record.incrementing(targetCount: 3)
        record = record.incrementing(targetCount: 3)
        record = record.incrementing(targetCount: 3)
        
        XCTAssertTrue(record.isCompleted)
        XCTAssertEqual(record.currentCount, 3)
    }
    
    func test_incrementing_byAmount_increasesCountProperly() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        let result = sut.incrementing(by: 60, targetCount: 900)
        
        XCTAssertEqual(result.currentCount, 60)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_decrementing_whenCompleted_uncompletes() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.incrementing(targetCount: 5)
        sut = sut.incrementing(targetCount: 5)
        sut = sut.incrementing(targetCount: 5)
        sut = sut.incrementing(targetCount: 5)
        sut = sut.incrementing(targetCount: 5)
        XCTAssertTrue(sut.isCompleted)
        
        let result = sut.decrementing(targetCount: 5)
        
        XCTAssertFalse(result.isCompleted)
        XCTAssertEqual(result.currentCount, 4)
    }
    
    func test_decrementing_fromPositive_decreasesCount() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.incrementing(targetCount: 10)
        sut = sut.incrementing(targetCount: 10)
        
        let result = sut.decrementing(targetCount: 10)
        
        XCTAssertEqual(result.currentCount, 1)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_decrementing_fromZero_staysAtZero() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        let result = sut.decrementing(targetCount: 5)
        
        XCTAssertEqual(result.currentCount, 0)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_decrementing_byAmount_decreasesCountProperly() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.incrementing(by: 120, targetCount: 900)
        
        let result = sut.decrementing(by: 60, targetCount: 900)
        
        XCTAssertEqual(result.currentCount, 60)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_incrementAndDecrement_immutability_preservesOriginal() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        _ = sut.incrementing(targetCount: 5)
        _ = sut.decrementing(targetCount: 5)
        
        XCTAssertEqual(sut.currentCount, 0)
        XCTAssertFalse(sut.isCompleted)
    }
    
    // MARK: togglingTimer
    
    func test_togglingTimer_whenNotRunning_startsTimer() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        let result = sut.togglingTimer(targetCount: 15)
        
        XCTAssertNotNil(result.timerStartDate)
        XCTAssertEqual(result.currentCount, 0)
        XCTAssertFalse(result.isCompleted)
    }
    
    func test_togglingTimer_whenRunning_stopsTimerAndCalculatesElapsed() {
        let itemId = UUID()
        let startDate = Date().addingTimeInterval(-60) // started 60 seconds ago
        let sut = DailyRecord(
            id: UUID(),
            itemId: itemId,
            date: Date(),
            currentCount: 10,
            isCompleted: false,
            timerStartDate: startDate,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let result = sut.togglingTimer(targetCount: 15)
        
        XCTAssertNil(result.timerStartDate)
        XCTAssertEqual(result.currentCount, 70) // 10 + 60
        XCTAssertFalse(result.isCompleted) // 70 < 15 * 60 (900)
    }
    
    func test_togglingTimer_whenRunning_reachesTarget_completes() {
        let itemId = UUID()
        let startDate = Date().addingTimeInterval(-900) // started 15 minutes ago
        let sut = DailyRecord(
            id: UUID(),
            itemId: itemId,
            date: Date(),
            currentCount: 0,
            isCompleted: false,
            timerStartDate: startDate,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let result = sut.togglingTimer(targetCount: 15)
        
        XCTAssertNil(result.timerStartDate)
        XCTAssertEqual(result.currentCount, 900)
        XCTAssertTrue(result.isCompleted) // 900 >= 15 * 60
    }
    
    // MARK: restarting
    
    func test_restarting_resetsCountAndCompletionAndTimer() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.incrementing(targetCount: 5)
        sut = sut.incrementing(targetCount: 5)
        XCTAssertEqual(sut.currentCount, 2)
        
        let result = sut.restarting()
        
        XCTAssertEqual(result.currentCount, 0)
        XCTAssertFalse(result.isCompleted)
        XCTAssertNil(result.timerStartDate)
    }
    
    func test_restarting_runningTimer_stopsTimerAndResets() {
        let itemId = UUID()
        var sut = DailyRecord.new(for: itemId, on: Date())
        sut = sut.togglingTimer(targetCount: 15)
        XCTAssertNotNil(sut.timerStartDate)
        
        let result = sut.restarting()
        
        XCTAssertEqual(result.currentCount, 0)
        XCTAssertFalse(result.isCompleted)
        XCTAssertNil(result.timerStartDate)
    }
}
