import XCTest
@testable import StreakOSFramework

final class ItemTests: XCTestCase {
    
    func test_init_setsProperties() {
        let id = UUID()
        let now = Date()
        let sut = Item(
            id: id,
            name: "Push Ups",
            icon: "💪",
            type: ItemType.count,
            targetCount: 10,
            startDate: now,
            endDate: nil,
            displayOrder: 5,
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.name, "Push Ups")
        XCTAssertEqual(sut.icon, "💪")
        XCTAssertEqual(sut.targetCount, 10)
        XCTAssertEqual(sut.startDate, now)
        XCTAssertNil(sut.endDate)
        XCTAssertEqual(sut.displayOrder, 5)
        XCTAssertEqual(sut.createdAt, now)
        XCTAssertEqual(sut.updatedAt, now)
    }
    
    func test_isVisible_onStartDate_returnsTrue() {
        let today = Date().startOfDay
        let sut = uniqueItem(startDate: today)
        
        XCTAssertTrue(sut.isVisible(on: today))
    }
    
    func test_isVisible_beforeStartDate_returnsFalse() {
        let today = Date().startOfDay
        let sut = uniqueItem(startDate: today.adding(days: 1))
        
        XCTAssertFalse(sut.isVisible(on: today))
    }
    
    func test_isVisible_afterStartDate_returnsTrue() {
        let today = Date().startOfDay
        let sut = uniqueItem(startDate: today.adding(days: -3))
        
        XCTAssertTrue(sut.isVisible(on: today))
    }
    
    func test_isVisible_withEndDate_beforeEndDate_returnsTrue() {
        let today = Date().startOfDay
        let sut = uniqueItem(
            startDate: today.adding(days: -5),
            endDate: today.adding(days: 5)
        )
        
        XCTAssertTrue(sut.isVisible(on: today))
    }
    
    func test_isVisible_onEndDate_returnsTrue() {
        let today = Date().startOfDay
        let sut = uniqueItem(
            startDate: today.adding(days: -5),
            endDate: today
        )
        
        XCTAssertTrue(sut.isVisible(on: today))
    }
    
    func test_isVisible_afterEndDate_returnsFalse() {
        let today = Date().startOfDay
        let sut = uniqueItem(
            startDate: today.adding(days: -5),
            endDate: today.adding(days: -1)
        )
        
        XCTAssertFalse(sut.isVisible(on: today))
    }
    
    func test_isVisible_withoutEndDate_futureDate_returnsTrue() {
        let today = Date().startOfDay
        let sut = uniqueItem(startDate: today)
        
        XCTAssertTrue(sut.isVisible(on: today.adding(days: 100)))
    }
    
    func test_isVisible_withRepeatSchedule_matchingDay_returnsTrue() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // 2026-08-24 is Monday
        var mondayComponents = DateComponents()
        mondayComponents.year = 2026
        mondayComponents.month = 8
        mondayComponents.day = 24
        let monday = calendar.date(from: mondayComponents)!
        
        let sut = uniqueItem(
            startDate: monday.adding(days: -10),
            repeatSchedule: RepeatSchedule.weekdays
        )
        
        XCTAssertTrue(sut.isVisible(on: monday))
    }
    
    func test_isVisible_withRepeatSchedule_nonMatchingDay_returnsFalse() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // 2026-08-29 is Saturday
        var saturdayComponents = DateComponents()
        saturdayComponents.year = 2026
        saturdayComponents.month = 8
        saturdayComponents.day = 29
        let saturday = calendar.date(from: saturdayComponents)!
        
        let sut = uniqueItem(
            startDate: saturday.adding(days: -10),
            repeatSchedule: RepeatSchedule.weekdays
        )
        
        XCTAssertFalse(sut.isVisible(on: saturday))
    }
}
