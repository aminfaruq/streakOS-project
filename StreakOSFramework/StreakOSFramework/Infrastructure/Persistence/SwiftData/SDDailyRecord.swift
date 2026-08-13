import Foundation
import SwiftData

@Model
public final class SDDailyRecord {
    public var id: UUID = UUID()
    public var itemId: UUID = UUID()
    public var date: Date = Date()
    public var currentCount: Int = 0
    public var isCompleted: Bool = false
    public var timerStartDate: Date?
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    public var item: SDItem?
    
    public init(
        id: UUID,
        itemId: UUID,
        date: Date,
        currentCount: Int,
        isCompleted: Bool,
        timerStartDate: Date? = nil,
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
}
