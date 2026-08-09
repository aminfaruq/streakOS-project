import XCTest
@testable import StreakOSFramework

final class ItemNameGeneratorTests: XCTestCase {

    // MARK: isNameUnique

    func test_isNameUnique_whenNoItems_returnsTrue() {
        XCTAssertTrue(ItemNameGenerator.isNameUnique("Push Ups", among: []))
    }

    func test_isNameUnique_whenNameNotUsed_returnsTrue() {
        let items = [uniqueItem(name: "Walk")]

        XCTAssertTrue(ItemNameGenerator.isNameUnique("Push Ups", among: items))
    }

    func test_isNameUnique_whenExactMatch_returnsFalse() {
        let items = [uniqueItem(name: "Walk")]

        XCTAssertFalse(ItemNameGenerator.isNameUnique("Walk", among: items))
    }

    func test_isNameUnique_isCaseInsensitive() {
        let items = [uniqueItem(name: "Walk")]

        XCTAssertFalse(ItemNameGenerator.isNameUnique("walk", among: items))
    }

    func test_isNameUnique_excludingItemId_allowsSameName() {
        let item = uniqueItem(name: "Walk")
        let items = [item]

        XCTAssertTrue(ItemNameGenerator.isNameUnique("Walk", among: items, excluding: item.id))
    }

    func test_isNameUnique_excludingOtherId_stillRejects() {
        let item = uniqueItem(name: "Walk")
        let items = [item]

        XCTAssertFalse(ItemNameGenerator.isNameUnique("Walk", among: items, excluding: UUID()))
    }

    // MARK: duplicateName

    func test_duplicateName_whenNoConflict_returnsOriginalWith2() {
        let items = [uniqueItem(name: "Walk")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk", among: items), "Walk 2")
    }

    func test_duplicateName_whenTwoTaken_returnsThree() {
        let items = [uniqueItem(name: "Walk"), uniqueItem(name: "Walk 2")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk", among: items), "Walk 3")
    }

    func test_duplicateName_whenMultipleTaken_returnsFirstFree() {
        let items = [
            uniqueItem(name: "Walk"),
            uniqueItem(name: "Walk 2"),
            uniqueItem(name: "Walk 3"),
        ]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk", among: items), "Walk 4")
    }

    func test_duplicateName_whenOriginalHasTrailingNumber_stripsToBase() {
        let items = [uniqueItem(name: "Walk 2")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk 2", among: items), "Walk 3")
    }

    func test_duplicateName_whenOriginalHasTrailingNumberAndBaseTaken() {
        let items = [uniqueItem(name: "Walk"), uniqueItem(name: "Walk 2")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk 2", among: items), "Walk 3")
    }

    func test_duplicateName_isCaseInsensitiveAgainstExisting() {
        let items = [uniqueItem(name: "WALK")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Walk", among: items), "Walk 2")
    }

    func test_duplicateName_whenOriginalIsUnnumbered_keepsNumberTwo() {
        let items = [uniqueItem(name: "Read Book")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "Read Book", among: items), "Read Book 2")
    }

    func test_duplicateName_originalNameOnlyNumber_unstripped() {
        let items = [uniqueItem(name: "7")]

        XCTAssertEqual(ItemNameGenerator.duplicateName(for: "7", among: items), "7 2")
    }
}