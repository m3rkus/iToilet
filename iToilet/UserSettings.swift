//
//  UserSettings.swift
//  iToilet
//
//  Created by Roman Anistratenko on 10.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Foundation

struct UserSettings {
    
    @UserSetting(
        key: "isNotificationEnabled",
        defaultValue: false)
    static var isNotificationEnabled: Bool
    
    @UserSetting(
        key: "isAutolaunchEnabled",
        defaultValue: false)
    static var isAutolaunchEnabled: Bool
    
    @UserSetting(
        key: "isToiletAvailableCurrentStatus",
        defaultValue: Optional.none)
    static var isToiletAvailableCurrentStatus: Bool?
}


@propertyWrapper
struct UserSetting<T> {
    
    let key: String
    let defaultValue: T

    init(
        key: String,
        defaultValue: T) {
        
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct CodableUserSetting<T: Codable> {
    
    let key: String
    let defaultValue: T

    init(
        key: String,
        defaultValue: T) {
        
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            do {
                let value = try JSONDecoder().decode(T.self, from: data)
                return value
            } catch {
                log.error("Unable to decode JSON of type \(T.self)", .general)
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                log.error("Unable to encode JSON of type \(T.self)", .general)
            }
        }
    }
}
