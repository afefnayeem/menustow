//
//  MenustowApp.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import SwiftUI

@main
struct MenustowApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        SettingsWindow(appState: appDelegate.appState)
        PermissionsWindow(appState: appDelegate.appState)
    }
}
