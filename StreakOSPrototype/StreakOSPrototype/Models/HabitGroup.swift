//
//  HabitGroup.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

struct HabitGroup: Identifiable, Equatable {
    let id: UUID
    var name: String
    var displayOrder: Int
}
