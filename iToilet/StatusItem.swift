//
//  StatusItem.swift
//  iToilet
//
//  Created by Roman Anistratenko on 11.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa

final class StatusItem {
    
    func makeStatusItem() -> NSStatusItem {
        
        let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("status_circle"))
        }
        return statusItem
    }
}
