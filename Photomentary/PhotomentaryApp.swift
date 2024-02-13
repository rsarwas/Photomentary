//
//  PhotomentaryApp.swift
//  Photomentary
//
//  Created by Regan Sarwas on 8/31/22.
//

import SwiftUI

@main
struct PhotomentaryApp: App {

  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .onChange(of: scenePhase) { phase in
      print("Scene Phase Change \(phase)")
      #if os(tvOS)
        if phase == .active {
          print("disable idle timer")
          UIApplication.shared.isIdleTimerDisabled = true
        } else {
          UIApplication.shared.isIdleTimerDisabled = false
        }
      #endif
    }
  }
}
