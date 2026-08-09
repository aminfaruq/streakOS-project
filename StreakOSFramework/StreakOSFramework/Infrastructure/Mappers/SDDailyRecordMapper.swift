import Foundation

enum SDDailyRecordMapper {
    
    static func toDomain(_ sdRecord: SDDailyRecord) -> DailyRecord {
        DailyRecord(
            id: sdRecord.id,
            itemId: sdRecord.itemId,
            date: sdRecord.date,
            currentCount: sdRecord.currentCount,
            isCompleted: sdRecord.isCompleted,
            createdAt: sdRecord.createdAt,
            updatedAt: sdRecord.updatedAt
        )
    }
    
    static func toDomainList(_ sdRecords: [SDDailyRecord]) -> [DailyRecord] {
        sdRecords.map(toDomain)
    }
    
    static func toSDModel(_ record: DailyRecord) -> SDDailyRecord {
        SDDailyRecord(
            id: record.id,
            itemId: record.itemId,
            date: record.date,
            currentCount: record.currentCount,
            isCompleted: record.isCompleted,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }
}
