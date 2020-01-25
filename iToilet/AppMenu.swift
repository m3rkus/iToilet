//
//  AppMenu.swift
//  iToilet
//
//  Created by Roman Anistratenko on 10.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa

final class AppMenu {
    
    // MARK: - Public Properties
    var onAppQuit: (() -> Void)?
    var onLaunchAtLogin: ((_ enabled: Bool) -> Void)?
    
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
        
    // MARK: - Setup
    func setup() {
        
        updateNotificationButtonState(enabled: UserSettings.isNotificationEnabled)
        updateAutolaunchButtonState(enabled: UserSettings.isAutolaunchEnabled)
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
        
        var isNotificationEnabled = UserSettings.isNotificationEnabled
        isNotificationEnabled.toggle()
        UserSettings.isNotificationEnabled = isNotificationEnabled
        updateNotificationButtonState(enabled: isNotificationEnabled)
    }
    
    private func updateNotificationButtonState(enabled: Bool) {
        
        notificationMenuItem.state = enabled
            ? .on
            : .off
    }
    
    @objc func tapAutolaunchButton() {
        
        var isAutolaunchEnabled = UserSettings.isAutolaunchEnabled
        isAutolaunchEnabled.toggle()
        UserSettings.isAutolaunchEnabled = isAutolaunchEnabled
        updateAutolaunchButtonState(enabled: isAutolaunchEnabled)
        onLaunchAtLogin?(isAutolaunchEnabled)
    }
    
    private func updateAutolaunchButtonState(enabled: Bool) {
        
        autolaunchMenuItem.state = enabled
            ? .on
            : .off
    }
    
    @objc func tapQuitButton() {
        
        onAppQuit?()
        NSApplication.shared.terminate(self)
    }
}
