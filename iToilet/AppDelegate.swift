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
    private let launcherService = LauncherService()
    private let appMenu = AppMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        launcherService.setLaunchAtLogin(enabled: UserSettings.isAutolaunchEnabled)
        launcherService.killLauncherIfNeeded()
        
        statusItem.menu = appMenu.makeMenu()
        appMenu.setup()
        appMenu.onAppQuit = { [weak self] in
            guard let self = self else { return }
            self.statusService.disconnect()
        }
        appMenu.onLaunchAtLogin = { [weak self] enabled in
            guard let self = self else { return }
            self.launcherService.setLaunchAtLogin(enabled: enabled)
        }
        appMenu.onReconnection = { [weak self] in
            guard let self = self else { return }
            self.statusService.connect()
        }
        
        statusService.delegate = self
        udpateStatusItem(isToiletAvailable: UserSettings.isToiletAvailableCurrentStatus ?? true)
        self.statusService.connect()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    private func udpateStatusItem(isToiletAvailable: Bool) {
        
        let statusImage = NSImage(named: NSImage.Name("status_circle"))
        statusItem.button?.image = isToiletAvailable
            ? statusImage?.imageWithTintColor(tintColor: NSColor(srgbRed: 0, green: 0.8, blue: 0, alpha: 1))
            : statusImage?.imageWithTintColor(tintColor: .red)
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
    
    private func updateToiletAvailableStatus(isToiletAvailable: Bool, force: Bool = false) {
        
        if !force,
            UserSettings.isToiletAvailableCurrentStatus != nil,
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

// MARK: - StatusMQTTServiceDelegate
extension AppDelegate: StatusMQTTServiceDelegate {
    
    func updateStatus(isToiletAvailable: Bool) {
        
        updateToiletAvailableStatus(isToiletAvailable: isToiletAvailable)
    }
    
    func updateConnectionStatus(isConnected: Bool) {
        
        appMenu.changeConnectionMenuItemState(isConnected: isConnected)
        if !isConnected {
            statusItem.button?.image = NSImage(named: NSImage.Name("status_circle"))?.imageWithTintColor(tintColor: .gray)
        } else {
            udpateStatusItem(isToiletAvailable: UserSettings.isToiletAvailableCurrentStatus ?? true)
        }
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
