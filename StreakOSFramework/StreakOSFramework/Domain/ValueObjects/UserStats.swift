//
//  UserStats.swift
//  StreakOSFramework
//
//  Created by Amin faruq on 06/08/26.
//

import Foundation

public struct UserStats: Equatable {
    public let totalActiveStreaks: Int
    public let overallCompletionRate: Double
    public let weeklyCompletions: [Date: Int]
    public let totalHabits: Int
    public let totalCompletions: Int
    
    public init(
        totalActiveStreaks: Int,
        overallCompletionRate: Double,
        weeklyCompletions: [Date: Int],
        totalHabits: Int,
        totalCompletions: Int
    ) {
        self.totalActiveStreaks = totalActiveStreaks
        self.overallCompletionRate = overallCompletionRate
        self.weeklyCompletions = weeklyCompletions
        self.totalHabits = totalHabits
        self.totalCompletions = totalCompletions
    }
}
