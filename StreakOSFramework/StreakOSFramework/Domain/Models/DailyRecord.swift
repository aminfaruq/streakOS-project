//
//  DailyRecord.swift
//  StreakOSFramework
//
//  Created by Amin faruq on 06/08/26.
//

import Foundation

public struct DailyRecord: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let habitId: UUID
    public let date: Date
    public var currentValue: Int
    public var isCompleted: Bool
    public var isTimerRunning: Bool
    public var timerStartedAt: Date?
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID,
        habitId: UUID,
        date: Date,
        currentValue: Int,
        isCompleted: Bool,
        isTimerRunning: Bool,
        timerStartedAt: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.currentValue = currentValue
        self.isCompleted = isCompleted
        self.isTimerRunning = isTimerRunning
        self.timerStartedAt = timerStartedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
