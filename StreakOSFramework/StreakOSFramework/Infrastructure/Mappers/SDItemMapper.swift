import Foundation

enum SDItemMapper {
    
    static func toDomain(_ sdItem: SDItem) -> Item {
        Item(
            id: sdItem.id,
            name: sdItem.name,
            icon: sdItem.icon,
            targetCount: sdItem.targetCount,
            startDate: sdItem.startDate,
            endDate: sdItem.endDate,
            displayOrder: sdItem.displayOrder,
            createdAt: sdItem.createdAt,
            updatedAt: sdItem.updatedAt
        )
    }
    
    static func toSDModel(_ item: Item) -> SDItem {
        SDItem(
            id: item.id,
            name: item.name,
            icon: item.icon,
            targetCount: item.targetCount,
            startDate: item.startDate,
            endDate: item.endDate,
            displayOrder: item.displayOrder,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }
    
    static func toDomainList(_ sdItems: [SDItem]) -> [Item] {
        sdItems.map(toDomain)
    }
}
