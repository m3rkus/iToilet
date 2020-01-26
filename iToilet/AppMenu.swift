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
    var onReconnection: (() -> Void)?
    
    // MARK: - Private Properties
    lazy var serverConnectionMenuItem: NSMenuItem = {
        let menuItem = NSMenuItem(
            title: "Соединение",
            action: nil,
            keyEquivalent: "")
        menuItem.state = .off
        return menuItem
    }()
    lazy var reconnectionMenuItem: NSMenuItem = {
        let menuItem = NSMenuItem(
            title: "Переподключиться",
            action: #selector(tapReconnectionButton),
            keyEquivalent: "r")
        menuItem.target = self
        return menuItem
    }()
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
        menu.addItem(serverConnectionMenuItem)
        menu.addItem(reconnectionMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(notificationMenuItem)
        menu.addItem(autolaunchMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuButton)
        changeConnectionMenuItemState(isConnected: false)
        return menu
    }
    
    func changeConnectionMenuItemState(isConnected: Bool) {
        
        let statusImage = NSImage(named: NSImage.Name("connection_circle"))
        serverConnectionMenuItem.image = isConnected
            ? statusImage?.imageWithTintColor(tintColor: NSColor(srgbRed: 0, green: 0.8, blue: 0, alpha: 1))
            : statusImage?.imageWithTintColor(tintColor: .red)
    }
    
    @objc func tapReconnectionButton() {
        
        onReconnection?()
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
