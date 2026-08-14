//
//  DailyRecord.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

struct DailyRecord: Identifiable, Equatable {
    let id: UUID
    let habitId: UUID
    let date: Date
    var currentValue: Int
    var isCompleted: Bool
    var isTimerRunning: Bool
    var timerStartedAt: Date?
}
