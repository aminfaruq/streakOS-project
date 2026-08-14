//
//  Habit.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

struct Habit: Identifiable, Equatable {
    
    let id: UUID
    var name: String
    var icon: String
    var goalType: GoalType
    var targetValue: Int
    var groupId: UUID?
    var startDate: Date
    var endDate: Date?
    var displayOrder: Int

    // MARK: - Display helpers

    var isTimerBased: Bool { goalType == .minutes }
    var isSimpleCheck: Bool { goalType == .check }
    var isCounter: Bool { !isTimerBased && !isSimpleCheck }
}
