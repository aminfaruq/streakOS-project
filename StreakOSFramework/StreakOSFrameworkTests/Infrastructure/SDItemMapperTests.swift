import XCTest
@testable import StreakOSFramework

final class SDItemMapperTests: XCTestCase {
    
    func test_toDomain_mapsAllFields() {
        let id = UUID()
        let now = Date()
        let end = now.adding(days: 7)
        let sdItem = SDItem(
            id: id,
            name: "Read",
            icon: "📖",
            targetCount: 3,
            startDate: now,
            endDate: end,
            displayOrder: 2,
            createdAt: now,
            updatedAt: now
        )
        
        let item = SDItemMapper.toDomain(sdItem)
        
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.name, "Read")
        XCTAssertEqual(item.icon, "📖")
        XCTAssertEqual(item.targetCount, 3)
        XCTAssertEqual(item.startDate, now)
        XCTAssertEqual(item.endDate, end)
        XCTAssertEqual(item.displayOrder, 2)
        XCTAssertEqual(item.createdAt, now)
        XCTAssertEqual(item.updatedAt, now)
    }
    
    func test_toSDModel_mapsAllFields() {
        let id = UUID()
        let now = Date()
        let item = Item(
            id: id,
            name: "Walk",
            icon: "🚶",
            targetCount: 1,
            startDate: now,
            endDate: nil,
            displayOrder: 0,
            createdAt: now,
            updatedAt: now
        )
        
        let sdItem = SDItemMapper.toSDModel(item)
        
        XCTAssertEqual(sdItem.id, id)
        XCTAssertEqual(sdItem.name, "Walk")
        XCTAssertEqual(sdItem.icon, "🚶")
        XCTAssertEqual(sdItem.targetCount, 1)
        XCTAssertEqual(sdItem.startDate, now)
        XCTAssertNil(sdItem.endDate)
        XCTAssertEqual(sdItem.displayOrder, 0)
        XCTAssertEqual(sdItem.createdAt, now)
        XCTAssertEqual(sdItem.updatedAt, now)
    }
    
    func test_toDomainList_mapsMultipleItems() {
        let now = Date()
        let sd1 = SDItem(id: UUID(), name: "A", icon: "🅰️", targetCount: 1, startDate: now, endDate: nil, displayOrder: 0, createdAt: now, updatedAt: now)
        let sd2 = SDItem(id: UUID(), name: "B", icon: "🅱️", targetCount: 2, startDate: now, endDate: nil, displayOrder: 1, createdAt: now, updatedAt: now)
        
        let items = SDItemMapper.toDomainList([sd1, sd2])
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].name, "A")
        XCTAssertEqual(items[1].name, "B")
    }
}
