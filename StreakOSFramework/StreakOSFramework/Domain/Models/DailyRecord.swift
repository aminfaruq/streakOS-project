import Foundation

public struct DailyRecord: Hashable {
    public let id: UUID
    public let itemId: UUID
    public let date: Date
    public let currentCount: Int
    public let isCompleted: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        itemId: UUID,
        date: Date,
        currentCount: Int,
        isCompleted: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.itemId = itemId
        self.date = date
        self.currentCount = currentCount
        self.isCompleted = isCompleted
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
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

public extension DailyRecord {
    func incrementing(targetCount: Int) -> DailyRecord {
        guard !isCompleted else { return self }
        let newCount = currentCount + 1
        return DailyRecord(
            id: id,
            itemId: itemId,
            date: date,
            currentCount: newCount,
            isCompleted: newCount >= targetCount,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }

    func decrementing(targetCount: Int) -> DailyRecord {
        if isCompleted {
            let newCount = targetCount - 1
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: newCount,
                isCompleted: false,
                createdAt: createdAt,
                updatedAt: Date()
            )
        } else {
            let newCount = max(0, currentCount - 1)
            return DailyRecord(
                id: id,
                itemId: itemId,
                date: date,
                currentCount: newCount,
                isCompleted: false,
                createdAt: createdAt,
                updatedAt: Date()
            )
        }
    }
}
