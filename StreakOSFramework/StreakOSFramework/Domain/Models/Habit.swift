//
//  Habit.swift
//  StreakOSFramework
//
//  Created by Amin faruq on 06/08/26.
//

import Foundation

public struct Habit: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let icon: String
    public let goalType: GoalType
    public let targetValue: Int
    public let groupId: UUID?
    public let startDate: Date
    public let endDate: Date?
    public let displayOrder: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        name: String,
        icon: String,
        goalType: GoalType,
        targetValue: Int,
        groupId: UUID?,
        startDate: Date,
        endDate: Date?,
        displayOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.goalType = goalType
        self.targetValue = targetValue
        self.groupId = groupId
        self.startDate = startDate
        self.endDate = endDate
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
