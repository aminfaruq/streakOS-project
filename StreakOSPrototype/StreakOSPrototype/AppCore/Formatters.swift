//
//  Formatters.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

import Foundation

enum Formatters {
    
    static let dateHeader: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = ""
        return f
    }()
    
    static func formatTime(_ totalSeconds: Int) -> String {
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
