//
//  AppSettings.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    
    static let shared = AppSettings()
    
    var theme: ThemeMode = .dark
    var notificationsEnabled: Bool = true
    var icloudSync: Bool = true
    
    private init() {}
}
