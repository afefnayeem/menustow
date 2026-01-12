//
//  AppNavigationState.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import Combine

/// The model for app-wide navigation.
@MainActor
final class AppNavigationState: ObservableObject {
    @Published var isAppFrontmost = false
    @Published var isSettingsPresented = false
    @Published var isMenustowBarPresented = false
    @Published var isSearchPresented = false
    @Published var settingsNavigationIdentifier: SettingsNavigationIdentifier = .general
}
