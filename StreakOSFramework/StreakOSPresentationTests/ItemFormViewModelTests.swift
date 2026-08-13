import XCTest
import StreakOSFramework
@testable import StreakOSPresentation

final class ItemCreatorSpy: ItemCreator {
    private(set) var receivedRequests = [Request]()
    
    struct Request: Equatable {
        let name: String
        let icon: String
        let targetCount: Int
        let startDate: Date
        let endDate: Date?
    }
    
    private var completions = [(ItemCreator.Result) -> Void]()
    
    func create(
        name: String,
        icon: String,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        completion: @escaping (ItemCreator.Result) -> Void
    ) {
        receivedRequests.append(Request(name: name, icon: icon, targetCount: targetCount, startDate: startDate, endDate: endDate))
        completions.append(completion)
    }
    
    func complete(with item: Item, at index: Int = 0) {
        completions[index](.success(item))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}

@MainActor
final class ItemFormViewModelTests: XCTestCase {
    
    func test_init_listsDefaults() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.icon, "📋")
        XCTAssertEqual(sut.targetCount, 1)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isSaving)
    }
    
    func test_canSave_emptyName_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = ""
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_validFields_isTrue() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = "💪"
        sut.targetCount = 10
        
        XCTAssertTrue(sut.canSave)
    }
    
    func test_canSave_over100Chars_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = String(repeating: "a", count: 101)
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_emptyIcon_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = ""
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_invalidTarget_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.targetCount = 0
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_endDateBeforeStartDate_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.startDate = Date().adding(days: 5)
        sut.endDate = Date()
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_save_validFields_requestsCreation() {
        let (sut, creator) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = "💪"
        sut.targetCount = 5
        let startDate = sut.startDate
        
        sut.save()
        
        XCTAssertEqual(creator.receivedRequests, [
            .init(name: "Push Ups", icon: "💪", targetCount: 5, startDate: startDate, endDate: nil)
        ])
    }
    
    func test_save_invalidName_doesNotRequestCreation() {
        let (sut, creator) = makeSUT()
        sut.name = ""
        
        sut.save()
        
        XCTAssertTrue(creator.receivedRequests.isEmpty)
    }
    
    func test_save_onSuccess_deliversCreatedItem() {
        let item = uniqueItem()
        var created: Item?
        let (sut, creator) = makeSUT(onCreated: { created = $0 })
        
        sut.name = "Push Ups"
        sut.save()
        
        creator.complete(with: item)
        XCTAssertEqual(created, item)
        XCTAssertFalse(sut.isSaving)
    }
    
    func test_save_onDuplicateName_deliversErrorMessage() {
        let (sut, creator) = makeSUT()
        sut.name = "Push Ups"
        sut.save()
        
        creator.complete(with: LocalItemCreator.Error.duplicateName)
        
        XCTAssertEqual(sut.errorMessage, "An item with this name already exists.")
        XCTAssertFalse(sut.isSaving)
    }
    
    func test_save_setsIsSavingDuringRequest() {
        let (sut, creator) = makeSUT()
        sut.name = "Push Ups"
        
        sut.save()
        
        XCTAssertTrue(sut.isSaving)
        
        creator.complete(with: uniqueItem())
    }
    
    func test_save_clearsErrorMessageBeforeSaving() {
        let (sut, _) = makeSUT()
        sut.name = ""
        sut.save()
        XCTAssertNotNil(sut.errorMessage)
        
        sut.name = "Push Ups"
        sut.save()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        onCreated: @escaping (Item) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ItemFormViewModel, creator: ItemCreatorSpy) {
        let creator = ItemCreatorSpy()
        let sut = ItemFormViewModel(creator: creator, onCreated: onCreated)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(creator, file: file, line: line)
        return (sut, creator)
    }
    
    private func uniqueItem() -> Item {
        Item(id: UUID(), name: "any", icon: "📋", targetCount: 1, startDate: Date(), endDate: nil, displayOrder: 0, createdAt: Date(), updatedAt: Date())
    }
}
