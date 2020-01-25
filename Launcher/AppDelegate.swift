//
//  AppDelegate.swift
//  Launcher
//
//  Created by Roman Anistratenko on 25.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let launcherService = LauncherService()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
            
        launcherService.launchMainAppIfNeeded()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

