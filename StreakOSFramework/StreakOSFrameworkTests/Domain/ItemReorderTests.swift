import XCTest
@testable import StreakOSFramework

final class ItemReorderTests: XCTestCase {
    
    func test_reorder_movesItemDownAndReassignsOrders() {
        let items = makeItems(names: ["A", "B", "C", "D"])
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 0, toIndex: 2)
        
        XCTAssertEqual(reordered.map(\.name), ["B", "C", "A", "D"])
        XCTAssertEqual(reordered.map(\.displayOrder), [0, 1, 2, 3])
    }
    
    func test_reorder_movesItemUpAndReassignsOrders() {
        let items = makeItems(names: ["A", "B", "C", "D"])
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 3, toIndex: 1)
        
        XCTAssertEqual(reordered.map(\.name), ["A", "D", "B", "C"])
        XCTAssertEqual(reordered.map(\.displayOrder), [0, 1, 2, 3])
    }
    
    func test_reorder_movingToSameIndex_returnsSameOrder() {
        let items = makeItems(names: ["A", "B", "C"])
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 1, toIndex: 1)
        
        XCTAssertEqual(reordered.map(\.name), ["A", "B", "C"])
        XCTAssertEqual(reordered.map(\.displayOrder), [0, 1, 2])
    }
    
    func test_reorder_movesItemToFirst() {
        let items = makeItems(names: ["A", "B", "C", "D"])
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 2, toIndex: 0)
        
        XCTAssertEqual(reordered.map(\.name), ["C", "A", "B", "D"])
        XCTAssertEqual(reordered.map(\.displayOrder), [0, 1, 2, 3])
    }
    
    func test_reorder_movesItemToLast() {
        let items = makeItems(names: ["A", "B", "C"])
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 0, toIndex: 2)
        
        XCTAssertEqual(reordered.map(\.name), ["B", "C", "A"])
        XCTAssertEqual(reordered.map(\.displayOrder), [0, 1, 2])
    }
    
    func test_reorder_outOfRangeIndex_returnsUnchanged() {
        let items = makeItems(names: ["A", "B", "C"])
        
        XCTAssertEqual(ItemReorder.reorder(items: items, fromIndex: 5, toIndex: 1), items)
        XCTAssertEqual(ItemReorder.reorder(items: items, fromIndex: 0, toIndex: 9), items)
    }
    
    func test_reorder_emptyList_returnsEmpty() {
        XCTAssertEqual(ItemReorder.reorder(items: [], fromIndex: 0, toIndex: 0), [])
    }
    
    func test_reorder_preservesItemIdentity() {
        let items = makeItems(names: ["A", "B", "C"])
        let target = items[2]
        
        let reordered = ItemReorder.reorder(items: items, fromIndex: 2, toIndex: 0)
        
        XCTAssertEqual(reordered[0].id, target.id)
    }
    
    // MARK: Helpers
    
    private func makeItems(names: [String], displayOrder: Int = 0) -> [Item] {
        names.enumerated().map { index, name in
            Item(
                id: UUID(),
                name: name,
                icon: "📋",
                targetCount: 1,
                startDate: Date(),
                endDate: nil,
                displayOrder: index,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
}
