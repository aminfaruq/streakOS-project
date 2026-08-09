import XCTest
@testable import StreakOSFramework

final class ItemTypeTests: XCTestCase {
    
    func test_allCases_containsCount() {
        XCTAssertEqual(ItemType.allCases, [.count])
    }
    
    func test_rawValue() {
        XCTAssertEqual(ItemType.count.rawValue, "count")
    }
}
