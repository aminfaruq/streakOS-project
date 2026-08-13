import Foundation
import SwiftData

@Model
public final class SDItem {
    public var id: UUID = UUID()
    public var name: String = ""
    public var icon: String = ""
    public var itemTypeRawValue: String = "count"
    public var targetCount: Int = 1
    public var startDate: Date = Date()
    public var endDate: Date?
    public var displayOrder: Int = 0
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \SDDailyRecord.item)
    public var records: [SDDailyRecord]?
    
    public init(
        id: UUID,
        name: String,
        icon: String,
        itemTypeRawValue: String = "count",
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
        self.itemTypeRawValue = itemTypeRawValue
        self.targetCount = targetCount
        self.startDate = startDate
        self.endDate = endDate
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
