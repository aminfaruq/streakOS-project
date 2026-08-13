import XCTest
@testable import StreakOSFramework

final class ItemTypeTests: XCTestCase {
    
    func test_allCases_containsCount() {
        XCTAssertEqual(ItemType.allCases, [.count, .minutes])
    }
    
    func test_rawValue() {
        XCTAssertEqual(ItemType.count.rawValue, "count")
        XCTAssertEqual(ItemType.minutes.rawValue, "minutes")
    }
}
