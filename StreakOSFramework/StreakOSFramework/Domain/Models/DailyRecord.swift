import Foundation

public struct DailyRecord: Hashable {
    public let id: UUID
    public let itemId: UUID
    public let date: Date
    public let currentCount: Int
    public let isCompleted: Bool
    public let timerStartDate: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        itemId: UUID,
        date: Date,
        currentCount: Int,
        isCompleted: Bool,
        timerStartDate: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.itemId = itemId
        self.date = date
        self.currentCount = currentCount
        self.isCompleted = isCompleted
        self.timerStartDate = timerStartDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public static func new(for itemId: UUID, on date: Date) -> DailyRecord {
        DailyRecord(
            id: UUID(),
            itemId: itemId,
            date: date,
            currentCount: 0,
            isCompleted: false,
            timerStartDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

public extension DailyRecord {
    func incrementing(by amount: Int = 1, targetCount: Int) -> DailyRecord {
        guard !isCompleted else { return self }
        let newCount = currentCount + amount
        return DailyRecord(
            id: id,
            itemId: itemId,
            date: date,
            currentCount: newCount,
            isCompleted: newCount >= targetCount,
            timerStartDate: timerStartDate,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func decrementing(by amount: Int = 1, targetCount: Int) -> DailyRecord {
        if isCompleted {
            let newCount = targetCount - amount
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: max(0, newCount),
                isCompleted: false,
                timerStartDate: timerStartDate,
                createdAt: createdAt,
                updatedAt: Date()
            )
        } else {
            let newCount = max(0, currentCount - amount)
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: newCount,
                isCompleted: false,
                timerStartDate: timerStartDate,
                createdAt: createdAt,
                updatedAt: Date()
            )
        }
    }
    
    func togglingTimer(targetCount: Int) -> DailyRecord {
        if let startDate = timerStartDate {
            // Stop timer
            let elapsed = Int(Date().timeIntervalSince(startDate))
            let newCount = currentCount + elapsed
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: newCount,
                isCompleted: newCount >= (targetCount * 60),
                timerStartDate: nil,
                createdAt: createdAt,
                updatedAt: Date()
            )
        } else {
            // Start timer
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: currentCount,
                isCompleted: false,
                timerStartDate: Date(),
                createdAt: createdAt,
                updatedAt: Date()
            )
        }
    }
    
    func restarting() -> DailyRecord {
        DailyRecord(
            id: id,
            itemId: itemId,
            date: date,
            currentCount: 0,
            isCompleted: false,
            timerStartDate: nil,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
