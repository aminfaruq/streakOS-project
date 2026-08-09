import Foundation

public enum ItemAccessibility: Equatable, Hashable {
    case editable
    case readOnly
    case inaccessible
}

public struct DateNavigationWindow: Equatable {
    public static let pastEditableDays = 7
    public static let futureReadOnlyDays = 1

    public let today: Date
    public let calendar: Calendar

    public init(
        today: Date,
        calendar: Calendar = Calendar.current
    ) {
        self.today = calendar.startOfDay(for: today)
        self.calendar = calendar
    }

    public var earliestEditableDate: Date {
        calendar.date(byAdding: .day, value: -Self.pastEditableDays, to: today) ?? today
    }

    public var latestReadableDate: Date {
        calendar.date(byAdding: .day, value: Self.futureReadOnlyDays, to: today) ?? today
    }

    public func accessibility(of date: Date) -> ItemAccessibility {
        let day = calendar.startOfDay(for: date)

        if day <= today && day >= earliestEditableDate {
            return .editable
        }
        if day == latestReadableDate && day > today {
            return .readOnly
        }
        return .inaccessible
    }

    public func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }

    public func canNavigateBackward(from date: Date) -> Bool {
        calendar.startOfDay(for: date) > earliestEditableDate
    }

    public func canNavigateForward(from date: Date) -> Bool {
        calendar.startOfDay(for: date) < latestReadableDate
    }
}