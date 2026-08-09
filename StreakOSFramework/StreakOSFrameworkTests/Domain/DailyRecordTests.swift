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
    
    func test_incrementAndDecrement_immutability_preservesOriginal() {
        let itemId = UUID()
        let sut = DailyRecord.new(for: itemId, on: Date())
        
        _ = sut.incrementing(targetCount: 5)
        _ = sut.decrementing(targetCount: 5)
        
        XCTAssertEqual(sut.currentCount, 0)
        XCTAssertFalse(sut.isCompleted)
    }
}
