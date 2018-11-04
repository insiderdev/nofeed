//
//  Configuration.swift
//  NoFeed
//
//  Created by Vova Seuruk on 11/4/18.
//  Copyright © 2018 Vova Seuruk. All rights reserved.
//

import Foundation

class Configuration {
    
    private init() {}
    
    static let shared: Configuration = Configuration()
    
    private let onboardingCompletedKey = "onboardingCompleted"
    private let isPremiumUserKey = "isPremium"
    
    var isPremiumUser: Bool {
        return UserDefaults.standard.bool(forKey: isPremiumUserKey)
    }
    
    var onboardingCompleted: Bool {
        return UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    func setIsPremium(_ isPremium: Bool) {
        UserDefaults.standard.set(isPremium, forKey: isPremiumUserKey)
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingCompletedKey)
    }
    
}
