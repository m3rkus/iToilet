//
//  LauncherService.swift
//  iToilet
//
//  Created by Roman Anistratenko on 25.01.2020.
//  Copyright © 2020 LetMeCode. All rights reserved.
//

import Cocoa
import ServiceManagement


extension Notification.Name {
    
    static let killLauncher = Notification.Name("killLauncher")
}


final class LauncherService {
    
    private let launcherAppId = "com.letmecode.m3rk.corp.ToiletLauncher"
    private let mainAppId = "com.letmecode.m3rk.corp.Toilet"
    private let appName = "Toilet"
    private let macOS = "MacOS"
    
    func killLauncherIfNeeded() {
        
        let runningApps = NSWorkspace.shared.runningApplications
        let isLauncherRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        log.info("Check is launcher running: \(isLauncherRunning)", .util)
        if isLauncherRunning {
            DistributedNotificationCenter.default().post(
                name: .killLauncher,
                object: Bundle.main.bundleIdentifier!)
        }
    }
    
    func setLaunchAtLogin(enabled: Bool) {
        
        log.info("Update laucher status enabled: \(enabled)", .util)
        SMLoginItemSetEnabled(launcherAppId as CFString, enabled)
    }
    
    func launchMainAppIfNeeded() {

        let runningApps = NSWorkspace.shared.runningApplications
        let isMainAppRunning = !runningApps.filter { $0.bundleIdentifier == mainAppId }.isEmpty
        log.info("Check is main app running: \(isMainAppRunning)", .util)
        
        if !isMainAppRunning {
            launchMainApp()
        } else {
            terminate()
        }
    }
    
    @objc func terminate() {
        
        log.info("Terminate launcher", .util)
        NSApp.terminate(nil)
    }
    
    func launchMainApp() {
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(self.terminate),
            name: .killLauncher,
            object: mainAppId)

        let originPath = Bundle.main.bundlePath as NSString
        var components = originPath.pathComponents
        components.removeLast()
        components.removeLast()
        components.removeLast()
        components.append(macOS)
        components.append(appName)

        let appPath = NSString.path(withComponents: components)
        
        log.info("Launch main app \noriginPath: \(originPath) \nappPath: \(appPath)", .util)

        NSWorkspace.shared.launchApplication(appPath)
    }
}
