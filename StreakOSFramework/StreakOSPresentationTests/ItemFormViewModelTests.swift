import XCTest
import StreakOSFramework
@testable import StreakOSPresentation

final class ItemCreatorSpy: ItemCreator {
    private(set) var receivedRequests = [Request]()
    
    struct Request: Equatable {
        let name: String
        let icon: String
        let type: ItemType
        let targetCount: Int
        let startDate: Date
        let endDate: Date?
        let repeatSchedule: RepeatSchedule?
    }
    
    private var completions = [(ItemCreator.Result) -> Void]()
    
    func create(
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        repeatSchedule: RepeatSchedule?,
        completion: @escaping (ItemCreator.Result) -> Void
    ) {
        receivedRequests.append(Request(name: name, icon: icon, type: .count, targetCount: targetCount, startDate: startDate, endDate: endDate, repeatSchedule: repeatSchedule))
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
        XCTAssertFalse(sut.isRepeating)
        XCTAssertTrue(sut.selectedDays.isEmpty)
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
    
    func test_canSave_isRepeatingWithEmptyDays_isFalse() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = "💪"
        sut.targetCount = 10
        sut.isRepeating = true
        sut.selectedDays = []
        
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_isRepeatingWithSelectedDays_isTrue() {
        let (sut, _) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = "💪"
        sut.targetCount = 10
        sut.isRepeating = true
        sut.selectedDays = [.monday]
        
        XCTAssertTrue(sut.canSave)
    }
    
    func test_presetHelpers_configureSelectedDays() {
        let (sut, _) = makeSUT()
        
        sut.setEveryday()
        XCTAssertEqual(sut.selectedDays.count, 7)
        
        sut.setWeekdays()
        XCTAssertEqual(sut.selectedDays, Set([.monday, .tuesday, .wednesday, .thursday, .friday]))
        
        sut.setWeekends()
        XCTAssertEqual(sut.selectedDays, Set([.saturday, .sunday]))
    }
    
    func test_toggleDay_addsAndRemovesDay() {
        let (sut, _) = makeSUT()
        
        sut.toggleDay(.monday)
        XCTAssertTrue(sut.selectedDays.contains(.monday))
        
        sut.toggleDay(.monday)
        XCTAssertFalse(sut.selectedDays.contains(.monday))
    }
    
    func test_save_validFields_requestsCreation() {
        let (sut, creator) = makeSUT()
        sut.name = "Push Ups"
        sut.icon = "💪"
        sut.targetCount = 5
        let startDate = sut.startDate
        
        sut.save()
        
        XCTAssertEqual(creator.receivedRequests, [
            .init(name: "Push Ups", icon: "💪", type: .count, targetCount: 5, startDate: startDate, endDate: nil, repeatSchedule: nil)
        ])
    }
    
    func test_save_withRepeatSchedule_requestsCreationWithSchedule() {
        let (sut, creator) = makeSUT()
        sut.name = "Gym"
        sut.icon = "🏋️"
        sut.targetCount = 1
        sut.isRepeating = true
        sut.setWeekdays()
        let startDate = sut.startDate
        
        sut.save()
        
        XCTAssertEqual(creator.receivedRequests, [
            .init(name: "Gym", icon: "🏋️", type: .count, targetCount: 1, startDate: startDate, endDate: nil, repeatSchedule: RepeatSchedule.weekdays)
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
    
    func test_init_withExistingItemWithoutSchedule_isRepeatingIsFalse() {
        let item = uniqueItem()
        let (sut, _) = makeEditSUT(item: item)
        
        XCTAssertTrue(sut.isEditing)
        XCTAssertFalse(sut.isRepeating)
        XCTAssertTrue(sut.selectedDays.isEmpty)
    }
    
    func test_init_withExistingItemWithSchedule_loadsSchedule() {
        let schedule = RepeatSchedule.weekdays
        let item = Item(id: UUID(), name: "Yoga", icon: "🧘‍♀️", type: .count, targetCount: 1, startDate: Date(), endDate: nil, repeatSchedule: schedule, displayOrder: 0, createdAt: Date(), updatedAt: Date())
        let (sut, _) = makeEditSUT(item: item)
        
        XCTAssertTrue(sut.isEditing)
        XCTAssertTrue(sut.isRepeating)
        XCTAssertEqual(sut.selectedDays, schedule.days)
    }
    
    func test_save_updatedItem_withRepeatSchedule_requestsUpdateWithSchedule() {
        let existing = uniqueItem()
        let (sut, updater) = makeEditSUT(item: existing)
        sut.isRepeating = true
        sut.setWeekends()
        
        sut.save()
        
        XCTAssertEqual(updater.receivedMessages.count, 1)
        XCTAssertEqual(updater.receivedMessages.first?.item.repeatSchedule, RepeatSchedule.weekends)
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
    
    private func makeEditSUT(
        item: Item,
        onUpdated: @escaping (Item) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ItemFormViewModel, updater: ItemUpdaterSpy) {
        let updater = ItemUpdaterSpy()
        let sut = ItemFormViewModel(updater: updater, item: item, onUpdated: onUpdated)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(updater, file: file, line: line)
        return (sut, updater)
    }
    
    private func uniqueItem() -> Item {
        Item(id: UUID(), name: "any", icon: "📋", type: .count, targetCount: 1, startDate: Date(), endDate: nil, displayOrder: 0, createdAt: Date(), updatedAt: Date())
    }
}
