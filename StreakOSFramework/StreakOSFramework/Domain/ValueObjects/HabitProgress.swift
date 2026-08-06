//
//  HabitProgress.swift
//  StreakOSFramework
//
//  Created by Amin faruq on 06/08/26.
//

import Foundation

public struct HabitProgress: Equatable {
    public let habit: Habit
    public let record: DailyRecord?
    public let streak: Int
    public let isActiveOnDate: Bool
    
    public init(
        habit: Habit,
        record: DailyRecord?,
        streak: Int,
        isActiveOnDate: Bool
    ) {
        self.habit = habit
        self.record = record
        self.streak = streak
        self.isActiveOnDate = isActiveOnDate
    }
}
