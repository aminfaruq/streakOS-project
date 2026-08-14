//
//  DependencyContainer.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation
import Observation

@MainActor
final class DependencyContainer {
    
    let store: MockStore
    let settings: AppSettings
    let config: EnvironmentConfig
}
