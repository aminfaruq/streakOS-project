import Foundation
import SwiftData

public enum StreakOSModelContainer {

    public static func makeCloudKitEnabled() throws -> ModelContainer {
        let configuration = ModelConfiguration(cloudKitDatabase: .automatic)
        return try ModelContainer(
            for: SDItem.self, SDDailyRecord.self,
            configurations: configuration
        )
    }

    public static func makeInMemory() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: SDItem.self, SDDailyRecord.self,
            configurations: configuration
        )
    }
}