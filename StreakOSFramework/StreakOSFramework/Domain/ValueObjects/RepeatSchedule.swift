import Foundation

public struct RepeatSchedule: Hashable, Codable {
    public let days: Set<Weekday>
    
    public init(days: Set<Weekday>) {
        self.days = days
    }
    
    public static let everyday = RepeatSchedule(days: Set(Weekday.allCases))
    public static let weekdays = RepeatSchedule(days: [.monday, .tuesday, .wednesday, .thursday, .friday])
    public static let weekends = RepeatSchedule(days: [.saturday, .sunday])
    
    public var isEveryday: Bool {
        days.count == 7
    }
    
    public var isWeekdays: Bool {
        days == Set([.monday, .tuesday, .wednesday, .thursday, .friday])
    }
    
    public var isWeekends: Bool {
        days == Set([.saturday, .sunday])
    }
    
    public func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let weekdayComponent = calendar.component(.weekday, from: date)
        guard let weekday = Weekday(rawValue: weekdayComponent) else { return false }
        return days.contains(weekday)
    }
    
    public var displayText: String {
        if isEveryday {
            return "Every day"
        } else if isWeekdays {
            return "Weekdays"
        } else if isWeekends {
            return "Weekends"
        } else if days.count == 1, let first = days.first {
            return "Every \(first.shortName)"
        } else {
            let selectedOrdered = Weekday.orderedDays.filter { days.contains($0) }
            return selectedOrdered.map(\.shortName).joined(separator: ", ")
        }
    }
}
