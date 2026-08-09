import XCTest
import SwiftData
@testable import StreakOSFramework

@MainActor
final class StreakOSModelContainerTests: XCTestCase {
    
    func test_makeInMemory_createsContainer() throws {
        let container = try StreakOSModelContainer.makeInMemory()
        
        let descriptor = FetchDescriptor<SDItem>()
        let count = try container.mainContext.fetchCount(descriptor)
        XCTAssertEqual(count, 0)
    }
}
