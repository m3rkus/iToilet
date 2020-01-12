//
//  ToiletLightStatusModel.swift
//  iToilet
//
//  Created by Roman Anistratenko on 11.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Foundation

struct ToiletLightStatusModel: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case status = "field1"
    }
    
    let status: String
}
