import XCTest
@testable import StreakOSFramework

final class DateNavigationWindowTests: XCTestCase {

    private var today: Date { Date().startOfDay }
    private var sut: DateNavigationWindow { DateNavigationWindow(today: today) }

    // MARK: accessibility

    func test_accessibility_today_isEditable() {
        XCTAssertEqual(sut.accessibility(of: today), .editable)
    }

    func test_accessibility_oneDayAgo_isEditable() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: -1)), .editable)
    }

    func test_accessibility_sevenDaysAgo_isEditable() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: -7)), .editable)
    }

    func test_accessibility_eightDaysAgo_isInaccessible() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: -8)), .inaccessible)
    }

    func test_accessibility_twoWeeksAgo_isInaccessible() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: -14)), .inaccessible)
    }

    func test_accessibility_tomorrow_isReadOnly() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: 1)), .readOnly)
    }

    func test_accessibility_twoDaysFromNow_isInaccessible() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: 2)), .inaccessible)
    }

    func test_accessibility_oneWeekFromNow_isInaccessible() {
        XCTAssertEqual(sut.accessibility(of: today.adding(days: 7)), .inaccessible)
    }

    // MARK: isToday

    func test_isToday_trueForToday() {
        XCTAssertTrue(sut.isToday(Date()))
    }

    func test_isToday_falseForOtherDay() {
        XCTAssertFalse(sut.isToday(today.adding(days: -1)))
        XCTAssertFalse(sut.isToday(today.adding(days: 1)))
    }

    // MARK: canNavigateBackward

    func test_canNavigateBackward_atToday_true() {
        XCTAssertTrue(sut.canNavigateBackward(from: today))
    }

    func test_canNavigateBackward_atSevenDaysAgo_false() {
        XCTAssertFalse(sut.canNavigateBackward(from: today.adding(days: -7)))
    }

    func test_canNavigateBackward_atYesterday_true() {
        XCTAssertTrue(sut.canNavigateBackward(from: today.adding(days: -1)))
    }

    func test_canNavigateBackward_atEightDaysAgo_false() {
        XCTAssertFalse(sut.canNavigateBackward(from: today.adding(days: -8)))
    }

    // MARK: canNavigateForward

    func test_canNavigateForward_atToday_true() {
        XCTAssertTrue(sut.canNavigateForward(from: today))
    }

    func test_canNavigateForward_atTomorrow_false() {
        XCTAssertFalse(sut.canNavigateForward(from: today.adding(days: 1)))
    }

    func test_canNavigateForward_atSevenDaysAgo_true() {
        XCTAssertTrue(sut.canNavigateForward(from: today.adding(days: -7)))
    }

    func test_canNavigateForward_eightDaysAgo_true() {
        XCTAssertTrue(sut.canNavigateForward(from: today.adding(days: -8)))
    }
}