//
//  MenuBarAppearanceSettingsPane.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import SwiftUI

struct MenuBarAppearanceSettingsPane: View {
    @ObservedObject var appearanceManager: MenuBarAppearanceManager

    var body: some View {
        MenuBarAppearanceEditor(appearanceManager: appearanceManager, location: .settings)
    }
}
