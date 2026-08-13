import XCTest
@testable import StreakOSFramework

final class SDDailyRecordMapperTests: XCTestCase {
    
    func test_toDomain_mapsAllFields() {
        let id = UUID()
        let itemId = UUID()
        let now = Date()
        let sdRecord = SDDailyRecord(
            id: id,
            itemId: itemId,
            date: now,
            currentCount: 4,
            isCompleted: false,
            timerStartDate: now,
            createdAt: now,
            updatedAt: now
        )
        
        let record = SDDailyRecordMapper.toDomain(sdRecord)
        
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.itemId, itemId)
        XCTAssertEqual(record.currentCount, 4)
        XCTAssertFalse(record.isCompleted)
        XCTAssertEqual(record.timerStartDate, now)
        XCTAssertEqual(record.createdAt, now)
        XCTAssertEqual(record.updatedAt, now)
    }
    
    func test_toSDModel_mapsAllFields() {
        let id = UUID()
        let itemId = UUID()
        let now = Date()
        let record = DailyRecord(
            id: id,
            itemId: itemId,
            date: now,
            currentCount: 10,
            isCompleted: true,
            timerStartDate: now,
            createdAt: now,
            updatedAt: now
        )
        
        let sdRecord = SDDailyRecordMapper.toSDModel(record)
        
        XCTAssertEqual(sdRecord.id, id)
        XCTAssertEqual(sdRecord.itemId, itemId)
        XCTAssertEqual(sdRecord.currentCount, 10)
        XCTAssertTrue(sdRecord.isCompleted)
        XCTAssertEqual(sdRecord.timerStartDate, now)
        XCTAssertEqual(sdRecord.createdAt, now)
        XCTAssertEqual(sdRecord.updatedAt, now)
    }
}
