import XCTest
@testable import StreakOSFramework

final class RepeatScheduleTests: XCTestCase {
    
    func test_weekday_properties() {
        XCTAssertEqual(Weekday.sunday.rawValue, 1)
        XCTAssertEqual(Weekday.monday.rawValue, 2)
        XCTAssertEqual(Weekday.tuesday.rawValue, 3)
        XCTAssertEqual(Weekday.wednesday.rawValue, 4)
        XCTAssertEqual(Weekday.thursday.rawValue, 5)
        XCTAssertEqual(Weekday.friday.rawValue, 6)
        XCTAssertEqual(Weekday.saturday.rawValue, 7)
        
        XCTAssertEqual(Weekday.monday.shortName, "Mon")
        XCTAssertEqual(Weekday.sunday.shortName, "Sun")
        XCTAssertEqual(Weekday.monday.singleLetter, "M")
        XCTAssertEqual(Weekday.sunday.singleLetter, "S")
        
        XCTAssertEqual(Weekday.orderedDays, [
            .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday
        ])
    }
    
    func test_presets_configuration() {
        let everyday = RepeatSchedule.everyday
        XCTAssertTrue(everyday.isEveryday)
        XCTAssertFalse(everyday.isWeekdays)
        XCTAssertFalse(everyday.isWeekends)
        XCTAssertEqual(everyday.days.count, 7)
        
        let weekdays = RepeatSchedule.weekdays
        XCTAssertFalse(weekdays.isEveryday)
        XCTAssertTrue(weekdays.isWeekdays)
        XCTAssertFalse(weekdays.isWeekends)
        XCTAssertEqual(weekdays.days, Set([.monday, .tuesday, .wednesday, .thursday, .friday]))
        
        let weekends = RepeatSchedule.weekends
        XCTAssertFalse(weekends.isEveryday)
        XCTAssertFalse(weekends.isWeekdays)
        XCTAssertTrue(weekends.isWeekends)
        XCTAssertEqual(weekends.days, Set([.saturday, .sunday]))
    }
    
    func test_contains_dateMatching() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // 2026-08-24 is a Monday
        var mondayComponents = DateComponents()
        mondayComponents.year = 2026
        mondayComponents.month = 8
        mondayComponents.day = 24
        let monday = calendar.date(from: mondayComponents)!
        
        // 2026-08-29 is a Saturday
        var saturdayComponents = DateComponents()
        saturdayComponents.year = 2026
        saturdayComponents.month = 8
        saturdayComponents.day = 29
        let saturday = calendar.date(from: saturdayComponents)!
        
        let weekdaysSchedule = RepeatSchedule.weekdays
        XCTAssertTrue(weekdaysSchedule.contains(monday, calendar: calendar))
        XCTAssertFalse(weekdaysSchedule.contains(saturday, calendar: calendar))
        
        let weekendsSchedule = RepeatSchedule.weekends
        XCTAssertFalse(weekendsSchedule.contains(monday, calendar: calendar))
        XCTAssertTrue(weekendsSchedule.contains(saturday, calendar: calendar))
    }
    
    func test_displayText() {
        XCTAssertEqual(RepeatSchedule.everyday.displayText, "Every day")
        XCTAssertEqual(RepeatSchedule.weekdays.displayText, "Weekdays")
        XCTAssertEqual(RepeatSchedule.weekends.displayText, "Weekends")
        
        let singleDay = RepeatSchedule(days: [.monday])
        XCTAssertEqual(singleDay.displayText, "Every Mon")
        
        let customDays = RepeatSchedule(days: [.wednesday, .monday, .friday])
        XCTAssertEqual(customDays.displayText, "Mon, Wed, Fri")
    }
    
    func test_codable_roundtrip() throws {
        let schedule = RepeatSchedule(days: [.monday, .wednesday, .friday])
        let encoded = try JSONEncoder().encode(schedule)
        let decoded = try JSONDecoder().decode(RepeatSchedule.self, from: encoded)
        
        XCTAssertEqual(schedule, decoded)
    }
}
