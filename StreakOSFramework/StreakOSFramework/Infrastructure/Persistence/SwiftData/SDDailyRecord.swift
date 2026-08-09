import Foundation
import SwiftData

@Model
public final class SDDailyRecord {
    @Attribute(.unique) public var id: UUID
    public var itemId: UUID
    public var date: Date
    public var currentCount: Int
    public var isCompleted: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public var item: SDItem?
    
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
}
