//
//  AppMenu.swift
//  iToilet
//
//  Created by Roman Anistratenko on 10.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa

final class AppMenu {
        
    // MARK: - Private Properties
    lazy var notificationMenuItem: NSMenuItem = {
        let menuItem = NSMenuItem(
            title: "Оповещения",
            action: #selector(tapNotificationButton),
            keyEquivalent: "n")
        menuItem.target = self
        return menuItem
    }()
    lazy var autolaunchMenuItem: NSMenuItem = {
        let menuItem = NSMenuItem(
            title: "Автозапуск",
            action: #selector(tapAutolaunchButton),
            keyEquivalent: "l")
        menuItem.target = self
        return menuItem
    }()
    lazy var quitMenuButton: NSMenuItem = {
        let menuItem = NSMenuItem(
            title: "Выйти",
            action: #selector(tapQuitButton),
            keyEquivalent: "q")
        menuItem.target = self
        return menuItem
    }()
    
    var isNotificationEnabled = UserSettings.isNotificationEnabled
    var isAutolaunchEnabled = UserSettings.isAutolaunchEnabled
    
    // MARK: - Setup
    func setup() {
        
        updateNotificationButtonState()
        updateAutolaunchButtonState()
    }
    
    // MARK: - Menu
    func makeMenu() -> NSMenu {
        
        let menu = NSMenu()
        menu.addItem(notificationMenuItem)
        menu.addItem(autolaunchMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuButton)
        return menu
    }
    
    @objc func tapNotificationButton() {
        
        isNotificationEnabled.toggle()
        UserSettings.isNotificationEnabled = isNotificationEnabled
        updateNotificationButtonState()
    }
    
    private func updateNotificationButtonState() {
        
        notificationMenuItem.state = isNotificationEnabled
            ? .on
            : .off
    }
    
    @objc func tapAutolaunchButton() {
        
        isAutolaunchEnabled.toggle()
        UserSettings.isAutolaunchEnabled = isAutolaunchEnabled
        updateAutolaunchButtonState()
    }
    
    private func updateAutolaunchButtonState() {
        
        autolaunchMenuItem.state = isAutolaunchEnabled
            ? .on
            : .off
    }
    
    @objc func tapQuitButton() {
        
        NSApplication.shared.terminate(self)
    }
}
