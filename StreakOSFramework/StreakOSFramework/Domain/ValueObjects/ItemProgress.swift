import Foundation

public struct ItemProgress: Identifiable, Equatable {
    public let item: Item
    public let record: DailyRecord?
    
    public var id: UUID { item.id }
    
    public var progressFraction: Double {
        guard let record else { return 0 }
        let target = item.type == .minutes ? Double(item.targetCount * 60) : Double(item.targetCount)
        return min(1.0, Double(record.currentCount) / target)
    }
    
    public var displayText: String {
        guard let record else { return "0/\(item.targetCount)" }
        if record.isCompleted { return "✓" }
        if item.type == .minutes {
            return "\(record.currentCount / 60)/\(item.targetCount)"
        }
        return "\(record.currentCount)/\(item.targetCount)"
    }
    
    public init(item: Item, record: DailyRecord?) {
        self.item = item
        self.record = record
    }
}
