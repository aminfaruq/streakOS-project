//
//  EnvironmentConfig.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

struct EnvironmentConfig {
    let isPreview: Bool
    let defaultTheme: ThemeMode
    
    static let `default` = EnvironmentConfig(isPreview: false, defaultTheme: .dark)
    
    static let preview = EnvironmentConfig(isPreview: true, defaultTheme: .dark)
}
