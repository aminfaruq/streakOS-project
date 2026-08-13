import Foundation

public struct ItemProgress: Identifiable, Equatable {
    public let item: Item
    public let record: DailyRecord?

    public var id: UUID { item.id }
    
    public var progressFraction: Double {
        guard let record else { return 0 }
        return Double(record.currentCount) / Double(item.targetCount)
    }
    
    public var displayText: String {
        guard let record else { return "0/\(item.targetCount)" }
        if record.isCompleted { return "✓" }
        return "\(record.currentCount)/\(item.targetCount)"
    }
    
    public init(item: Item, record: DailyRecord?) {
        self.item = item
        self.record = record
    }
}
