//
//  HabitGroup.swift
//  StreakOSFramework
//
//  Created by Amin faruq on 06/08/26.
//

import Foundation

public struct HabitGroup: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var displayOrder: Int
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID,
        name: String,
        displayOrder: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.displayOrder = displayOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
