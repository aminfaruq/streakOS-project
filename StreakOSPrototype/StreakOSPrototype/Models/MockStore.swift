//
//  MockStore.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class MockStore {
    
    static let shared = MockStore()
    
    // MARK: - State
    
    var habits: [Habit] = []
    var records: [UUID: [Date: DailyRecord]] = [:]
    var groups: [HabitGroup] = []
    var selectedDate: Date = .startOfToday
    var isEditMode: Bool = false
    var subscription: SubscriptionStatus = .free
    
    
    private init() {
        seed()
    }
    
    private func seed() {
        
    }
    
    private func seedCompletedStreak() {
        
    }
    
    func record() {
        
    }
    
    func setRecord() {
        
    }
    
    func updateRecord() {
        
    }
    
    
    func habitsVisible() {
        
    }
    
    func ungroupedHabits() {
        
    }
    
    func habits(in group: HabitGroup, on date: Date) {
        
    }
    
    func streak() {
        
    }
    
    
    func toggleCheck() {
        
    }
    
    func toggleTimer() {
        
    }
    
    func advanceTimer() {
        
    }
    
    func increment() {
        
    }
    
    func decrement() {
        
    }
    
    func delete() {
        
    }
    
    func setProgress() {
        
    }
}

extension Date {
    
    static var startOfToday: Date { Date().startOfDay }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
