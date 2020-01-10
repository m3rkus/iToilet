//
//  AppDelegate.swift
//  iToilet
//
//  Created by Roman Anistratenko on 10.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let appMenu = AppMenu()
    let statusItem = StatusItem().makeStatusItem()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.menu = appMenu.makeMenu()
        appMenu.setup()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

