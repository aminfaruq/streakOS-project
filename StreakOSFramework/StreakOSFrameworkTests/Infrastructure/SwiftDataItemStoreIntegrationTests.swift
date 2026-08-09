import XCTest
import SwiftData
@testable import StreakOSFramework

@MainActor
final class SwiftDataItemStoreIntegrationTests: XCTestCase {

    private var container: ModelContainer!

    override func setUp() {
        super.setUp()
        container = try! StreakOSModelContainer.makeInMemory()
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SwiftDataItemStore {
        SwiftDataItemStore(modelContainer: container)
    }

    func test_retrieveAll_emptyStore_returnsEmptyList() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieveAll")

        sut.retrieveAll { result in
            switch result {
            case let .success(items):
                XCTAssertTrue(items.isEmpty)
            case .failure:
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_saveAndRetrieve_persistsItem() {
        let sut = makeSUT()
        let item = uniqueItem(name: "Push Ups", targetCount: 10)

        let saveExp = expectation(description: "save")
        sut.save(item) { result in
            if case .failure = result { XCTFail("Save failed") }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)

        let retrieveExp = expectation(description: "retrieveAll")
        sut.retrieveAll { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].id, item.id)
                XCTAssertEqual(items[0].name, item.name)
                XCTAssertEqual(items[0].targetCount, item.targetCount)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }

    func test_save_updatesExistingItem() {
        let sut = makeSUT()
        let item = uniqueItem(name: "Old Name")

        let save1Exp = expectation(description: "save1")
        sut.save(item) { _ in save1Exp.fulfill() }
        wait(for: [save1Exp], timeout: 1.0)

        let changedItem = Item(
            id: item.id,
            name: "New Name",
            icon: item.icon,
            targetCount: 7,
            startDate: item.startDate,
            endDate: item.endDate,
            displayOrder: item.displayOrder,
            createdAt: item.createdAt,
            updatedAt: Date()
        )

        let save2Exp = expectation(description: "save2")
        sut.save(changedItem) { _ in save2Exp.fulfill() }
        wait(for: [save2Exp], timeout: 1.0)

        let retrieveExp = expectation(description: "retrieve")
        sut.retrieveAll { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].name, "New Name")
                XCTAssertEqual(items[0].targetCount, 7)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }

    func test_delete_removesItem() {
        let sut = makeSUT()
        let item = uniqueItem()

        let saveExp = expectation(description: "save")
        sut.save(item) { _ in saveExp.fulfill() }
        wait(for: [saveExp], timeout: 1.0)

        let deleteExp = expectation(description: "delete")
        sut.delete(item) { _ in deleteExp.fulfill() }
        wait(for: [deleteExp], timeout: 1.0)

        let retrieveExp = expectation(description: "retrieve")
        sut.retrieveAll { result in
            switch result {
            case let .success(items):
                XCTAssertTrue(items.isEmpty)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }

    func test_retrieveAll_sortsByDisplayOrder() {
        let sut = makeSUT()
        let item1 = Item(id: UUID(), name: "B", icon: "🅱️", targetCount: 1, startDate: Date(), endDate: nil, displayOrder: 2, createdAt: Date(), updatedAt: Date())
        let item2 = Item(id: UUID(), name: "A", icon: "🅰️", targetCount: 1, startDate: Date(), endDate: nil, displayOrder: 0, createdAt: Date(), updatedAt: Date())

        let save1Exp = expectation(description: "save1")
        sut.save(item1) { _ in save1Exp.fulfill() }
        wait(for: [save1Exp], timeout: 1.0)

        let save2Exp = expectation(description: "save2")
        sut.save(item2) { _ in save2Exp.fulfill() }
        wait(for: [save2Exp], timeout: 1.0)

        let retrieveExp = expectation(description: "retrieve")
        sut.retrieveAll { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 2)
                XCTAssertEqual(items[0].displayOrder, 0)
                XCTAssertEqual(items[1].displayOrder, 2)
            case .failure:
                XCTFail("Expected success")
            }
            retrieveExp.fulfill()
        }
        wait(for: [retrieveExp], timeout: 1.0)
    }
}
