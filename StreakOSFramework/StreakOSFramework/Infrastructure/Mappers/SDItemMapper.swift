import Foundation

enum SDItemMapper {
    
    static func toDomain(_ sdItem: SDItem) -> Item {
        let repeatSchedule: RepeatSchedule? = sdItem.repeatDays.map { days in
            RepeatSchedule(days: Set(days.compactMap(Weekday.init)))
        }
        
        return Item(
            id: sdItem.id,
            name: sdItem.name,
            icon: sdItem.icon,
            type: ItemType(rawValue: sdItem.itemTypeRawValue) ?? .count,
            targetCount: sdItem.targetCount,
            startDate: sdItem.startDate,
            endDate: sdItem.endDate,
            repeatSchedule: repeatSchedule,
            displayOrder: sdItem.displayOrder,
            createdAt: sdItem.createdAt,
            updatedAt: sdItem.updatedAt
        )
    }
    
    static func toSDModel(_ item: Item) -> SDItem {
        let repeatDays: [Int]? = item.repeatSchedule.map { schedule in
            schedule.days.map(\.rawValue).sorted()
        }
        
        return SDItem(
            id: item.id,
            name: item.name,
            icon: item.icon,
            itemTypeRawValue: item.type.rawValue,
            targetCount: item.targetCount,
            startDate: item.startDate,
            endDate: item.endDate,
            repeatDays: repeatDays,
            displayOrder: item.displayOrder,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }
    
    static func toDomainList(_ sdItems: [SDItem]) -> [Item] {
        sdItems.map(toDomain)
    }
}
