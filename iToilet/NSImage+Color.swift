//
//  NSImage+Color.swift
//  iToilet
//
//  Created by Roman Anistratenko on 22.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa

extension NSImage {
    
    func imageWithTintColor(tintColor: NSColor) -> NSImage {
        
        if self.isTemplate == false {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        let fillingRect = NSMakeRect(0, 0, image.size.width, image.size.height)
        fillingRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}
