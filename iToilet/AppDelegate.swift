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

    let statusItem = StatusItem().makeStatusItem()
    private let statusService = StatusMQTTService()
    private let appMenu = AppMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.menu = appMenu.makeMenu()
        appMenu.setup()
        appMenu.onAppQuit = { [weak self] in
            guard let self = self else { return }
            self.statusService.disconnect()
        }
        statusService.delegate = self
        udpateStatusItem(isToiletAvailable: true)
        statusService.connect()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
    
    private func udpateStatusItem(isToiletAvailable: Bool) {
        
        statusItem.button?.contentTintColor = isToiletAvailable
            ? NSColor(srgbRed: 0, green: 0.8, blue: 0, alpha: 1)
            : .red
    }
    
    private func presentNotification(isToiletAvailable: Bool) {
        
        let notification = NSUserNotification()
        notification.title = isToiletAvailable
            ? "Туалет освободился"
            : "Туалет занят"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
}

// MARK: - StatusMQTTServiceDelegate
extension AppDelegate: StatusMQTTServiceDelegate {
    
    func updateStatus(isToiletAvailable: Bool) {
        
        if UserSettings.isToiletAvailableCurrentStatus != nil,
            UserSettings.isToiletAvailableCurrentStatus == isToiletAvailable {
            return
        }
        udpateStatusItem(isToiletAvailable: isToiletAvailable)
        if UserSettings.isNotificationEnabled {
            presentNotification(isToiletAvailable: isToiletAvailable)
        }
        UserSettings.isToiletAvailableCurrentStatus = isToiletAvailable
    }
}

// MARK: - NSUserNotificationCenterDelegate
extension AppDelegate: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification) -> Bool {
            
        return true
    }
}
