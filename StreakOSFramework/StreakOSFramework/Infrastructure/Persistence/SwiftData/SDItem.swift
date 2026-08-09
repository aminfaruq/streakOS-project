import Foundation
import SwiftData

@Model
public final class SDItem {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var icon: String
    public var targetCount: Int
    public var startDate: Date
    public var endDate: Date?
    public var displayOrder: Int
    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SDDailyRecord.item)
    public var records: [SDDailyRecord]?

    public init(
        id: UUID,
        name: String,
        icon: String,
        targetCount: Int,
        startDate: Date,
        endDate: Date?,
        displayOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.targetCount = targetCount
        self.startDate = startDate
        self.endDate = endDate
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
