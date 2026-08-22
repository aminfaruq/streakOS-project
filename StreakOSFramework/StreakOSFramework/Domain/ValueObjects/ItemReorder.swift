import Foundation

public enum ItemReorder {
    
    public static func reorder(
        items: [Item],
        fromIndex: Int,
        toIndex: Int
    ) -> [Item] {
        guard items.indices.contains(fromIndex), items.indices.contains(toIndex) else {
            return items
        }
        
        var reordered = items
        let moved = reordered.remove(at: fromIndex)
        reordered.insert(moved, at: toIndex)
        
        return reordered.enumerated().map { index, item in
            Item(
                id: item.id,
                name: item.name,
                icon: item.icon,
                type: item.type,
                targetCount: item.targetCount,
                startDate: item.startDate,
                endDate: item.endDate,
                repeatSchedule: item.repeatSchedule,
                displayOrder: index,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt
            )
        }
    }
}
