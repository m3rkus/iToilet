//
//  MQTTChannel.swift
//  iToilet
//
//  Created by Roman Anistratenko on 11.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Foundation

enum MQTTChannel {
    
    case toiletLightStatus
    
    var readApiKey: String {
        switch self {
        case .toiletLightStatus:
            return "EYN2PYVIP88S6EZE"
        }
    }
    
    var id: String {
        switch self {
        case .toiletLightStatus:
            return "559159"
        }
    }
}
