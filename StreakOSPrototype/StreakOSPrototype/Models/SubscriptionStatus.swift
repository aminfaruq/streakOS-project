//
//  SubscriptionStatus.swift
//  StreakOSPrototype
//
//  Created by Amin faruq on 15/07/26.
//

enum SubscriptionStatus: Equatable {
    case free
    case pro
    
    var isPro: Bool { self == .pro }
    var habbitLimit: Int { self == .free ? 3 : Int.max }
}
