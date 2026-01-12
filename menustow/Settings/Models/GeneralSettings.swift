//
//  GeneralSettings.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import Combine
import OSLog
import SwiftUI

// MARK: - GeneralSettings

/// Model for the app's General settings.
@MainActor
final class GeneralSettings: ObservableObject {
    /// A Boolean value that indicates whether the menustow icon
    /// should be shown.
    @Published var showMenustowIcon = true

    /// An icon to show in the menu bar, with a different image
    /// for when items are visible or hidden.
    @Published var menustowIcon: ControlItemImageSet = .defaultMenustowIcon

    /// The last user-selected custom menustow icon.
    @Published var lastCustomMenustowIcon: ControlItemImageSet?

    /// A Boolean value that indicates whether custom menustow icons
    /// should be rendered as template images.
    @Published var customMenustowIconIsTemplate = false

    /// A Boolean value that indicates whether to show hidden items
    /// in a separate bar below the menu bar.
    @Published var useMenustowBar = false

    /// The location where the menustow Bar appears.
    @Published var menustowBarLocation: MenustowBarLocation = .dynamic

    /// A Boolean value that indicates whether the hidden section
    /// should be shown when the mouse pointer clicks in an empty
    /// area of the menu bar.
    @Published var showOnClick = true

    /// A Boolean value that indicates whether the hidden section
    /// should be shown when the mouse pointer hovers over an
    /// empty area of the menu bar.
    @Published var showOnHover = false

    /// A Boolean value that indicates whether the hidden section
    /// should be shown or hidden when the user scrolls in the
    /// menu bar.
    @Published var showOnScroll = true

    /// The offset to apply to the menu bar item spacing and padding.
    @Published var itemSpacingOffset: Double = 0

    /// A Boolean value that indicates whether the hidden section
    /// should automatically rehide.
    @Published var autoRehide = true

    /// A strategy that determines how the auto-rehide feature works.
    @Published var rehideStrategy: RehideStrategy = .smart

    /// A time interval for the auto-rehide feature when its rule
    /// is ``RehideStrategy/timed``.
    @Published var rehideInterval: TimeInterval = 15

    /// Encoder for properties.
    private let encoder = JSONEncoder()

    /// Decoder for properties.
    private let decoder = JSONDecoder()

    /// Storage for internal observers.
    private var cancellables = Set<AnyCancellable>()

    /// The shared app state.
    private(set) weak var appState: AppState?

    /// Performs the initial setup of the model.
    func performSetup(with appState: AppState) {
        self.appState = appState
        loadInitialState()
        configureCancellables()
    }

    /// Loads the model's initial state.
    private func loadInitialState() {
        Defaults.ifPresent(key: .showMenustowIcon, assign: &showMenustowIcon)
        Defaults.ifPresent(key: .customMenustowIconIsTemplate, assign: &customMenustowIconIsTemplate)
        Defaults.ifPresent(key: .useMenustowBar, assign: &useMenustowBar)
        Defaults.ifPresent(key: .showOnClick, assign: &showOnClick)
        Defaults.ifPresent(key: .showOnHover, assign: &showOnHover)
        Defaults.ifPresent(key: .showOnScroll, assign: &showOnScroll)
        Defaults.ifPresent(key: .itemSpacingOffset, assign: &itemSpacingOffset)
        Defaults.ifPresent(key: .autoRehide, assign: &autoRehide)
        Defaults.ifPresent(key: .rehideInterval, assign: &rehideInterval)

        Defaults.ifPresent(key: .menustowBarLocation) { rawValue in
            if let location = MenustowBarLocation(rawValue: rawValue) {
                menustowBarLocation = location
            }
        }
        Defaults.ifPresent(key: .rehideStrategy) { rawValue in
            if let strategy = RehideStrategy(rawValue: rawValue) {
                rehideStrategy = strategy
            }
        }

        if let data = Defaults.data(forKey: .menustowIcon) {
            do {
                menustowIcon = try decoder.decode(ControlItemImageSet.self, from: data)
            } catch {
                Logger.serialization.error("Error decoding menustow icon: \(error, privacy: .public)")
            }
            if case .custom = menustowIcon.name {
                lastCustomMenustowIcon = menustowIcon
            }
        }
    }

    /// Configures the internal observers for the model.
    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        $showMenustowIcon
            .receive(on: DispatchQueue.main)
            .sink { showMenustowIcon in
                Defaults.set(showMenustowIcon, forKey: .showMenustowIcon)
            }
            .store(in: &c)

        $menustowIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] menustowIcon in
                guard let self else {
                    return
                }
                if case .custom = menustowIcon.name {
                    lastCustomMenustowIcon = menustowIcon
                }
                do {
                    let data = try encoder.encode(menustowIcon)
                    Defaults.set(data, forKey: .menustowIcon)
                } catch {
                    Logger.serialization.error("Error encoding menustow icon: \(error, privacy: .public)")
                }
            }
            .store(in: &c)

        $customMenustowIconIsTemplate
            .receive(on: DispatchQueue.main)
            .sink { isTemplate in
                Defaults.set(isTemplate, forKey: .customMenustowIconIsTemplate)
            }
            .store(in: &c)

        $useMenustowBar
            .receive(on: DispatchQueue.main)
            .sink { useMenustowBar in
                Defaults.set(useMenustowBar, forKey: .useMenustowBar)
            }
            .store(in: &c)

        $menustowBarLocation
            .receive(on: DispatchQueue.main)
            .sink { location in
                Defaults.set(location.rawValue, forKey: .menustowBarLocation)
            }
            .store(in: &c)

        $showOnClick
            .receive(on: DispatchQueue.main)
            .sink { showOnClick in
                Defaults.set(showOnClick, forKey: .showOnClick)
            }
            .store(in: &c)

        $showOnHover
            .receive(on: DispatchQueue.main)
            .sink { showOnHover in
                Defaults.set(showOnHover, forKey: .showOnHover)
            }
            .store(in: &c)

        $showOnScroll
            .receive(on: DispatchQueue.main)
            .sink { showOnScroll in
                Defaults.set(showOnScroll, forKey: .showOnScroll)
            }
            .store(in: &c)

        $itemSpacingOffset
            .receive(on: DispatchQueue.main)
            .sink { [weak appState] offset in
                Defaults.set(offset, forKey: .itemSpacingOffset)
                appState?.spacingManager.offset = Int(offset)
            }
            .store(in: &c)

        $autoRehide
            .receive(on: DispatchQueue.main)
            .sink { autoRehide in
                Defaults.set(autoRehide, forKey: .autoRehide)
            }
            .store(in: &c)

        $rehideStrategy
            .receive(on: DispatchQueue.main)
            .sink { strategy in
                Defaults.set(strategy.rawValue, forKey: .rehideStrategy)
            }
            .store(in: &c)

        $rehideInterval
            .receive(on: DispatchQueue.main)
            .sink { interval in
                Defaults.set(interval, forKey: .rehideInterval)
            }
            .store(in: &c)

        cancellables = c
    }
}

// MARK: - RehideStrategy

/// A type that determines how the auto-rehide feature works.
enum RehideStrategy: Int, CaseIterable, Identifiable {
    /// Menu bar items are rehidden using a smart algorithm.
    case smart = 0
    /// Menu bar items are rehidden after a given time interval.
    case timed = 1
    /// Menu bar items are rehidden when the focused app changes.
    case focusedApp = 2

    var id: Int { rawValue }

    /// Localized string key representation.
    var localized: LocalizedStringKey {
        switch self {
        case .smart: "Smart"
        case .timed: "Timed"
        case .focusedApp: "Focused app"
        }
    }
}
