//
//  PhotomentaryApp.swift
//  Photomentary
//
//  Created by Regan Sarwas on 8/31/22.
//

import SwiftUI

@main
struct PhotomentaryApp: App {
    #if os(tvOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(tvOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        application.isIdleTimerDisabled = true
    }
}
#endif
