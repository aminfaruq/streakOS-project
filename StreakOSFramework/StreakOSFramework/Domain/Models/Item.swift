import Foundation

public struct Item: Hashable {
    public let id: UUID
    public let name: String
    public let icon: String
    public let type: ItemType
    public let targetCount: Int
    public let startDate: Date
    public let endDate: Date?
    public let repeatSchedule: RepeatSchedule?
    public let displayOrder: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        name: String,
        icon: String,
        type: ItemType,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        repeatSchedule: RepeatSchedule? = nil,
        displayOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.targetCount = targetCount
        self.startDate = startDate
        self.endDate = endDate
        self.repeatSchedule = repeatSchedule
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public extension Item {
    func isVisible(on date: Date) -> Bool {
        let calendar = Calendar.current
        let itemStart = calendar.startOfDay(for: startDate)
        let targetDate = calendar.startOfDay(for: date)
        if targetDate < itemStart { return false }
        if let endDate, targetDate > calendar.startOfDay(for: endDate) { return false }
        if let repeatSchedule, !repeatSchedule.contains(date, calendar: calendar) {
            return false
        }
        return true
    }
}
