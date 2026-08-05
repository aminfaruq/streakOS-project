//
//  GoalType.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

enum GoalType: String, CaseIterable, Equatable, Identifiable {
    case check
    case minutes
    case pages
    case bottles
    case cups
    case litres
    case chapter
    
    var id: String { rawValue }
    
    var chipLabel: String {
        switch self {
        case .check:   return "Simple"
        case .minutes: return "Timer"
        case .pages:   return "Pages"
        case .bottles: return "Bottles"
        case .cups:    return "Cups"
        case .litres:  return "Litres"
        case .chapter: return "Chapter"
        }
    }

    var chipIcon: String {
        switch self {
        case .check:   return "✅"
        case .minutes: return "⏱️"
        case .pages:   return "📖"
        case .bottles: return "🍼"
        case .cups:    return "☕"
        case .litres:  return "💧"
        case .chapter: return "📑"
        }
    }

    // Unit label shown next to the stepper / progress tag
    var unitLabel: String {
        switch self {
        case .check:   return ""
        case .minutes: return "Min"
        case .pages:   return "Pages"
        case .bottles: return "Bottles"
        case .cups:    return "Cups"
        case .litres:  return "Litres"
        case .chapter: return "Chapter"
        }
    }

    var needsTarget: Bool {
        self != .check
    }
    
}
