import Foundation
@testable import StreakOSFramework

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func uniqueItem(
    name: String = "any name",
    targetCount: Int = 1,
    startDate: Date = Date(),
    endDate: Date? = nil
) -> Item {
    Item(
        id: UUID(),
        name: name,
        icon: "📋",
        type: ItemType.count,
        targetCount: targetCount,
        startDate: startDate,
        endDate: endDate,
        displayOrder: 0,
        createdAt: Date(),
        updatedAt: Date()
    )
}

func uniqueRecord(
    itemId: UUID = UUID(),
    currentCount: Int = 0,
    isCompleted: Bool = false
) -> DailyRecord {
    DailyRecord.new(for: itemId, on: Date())
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
