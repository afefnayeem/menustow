//
//  MenustowBarLocation.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import SwiftUI

/// Locations where the menustow Bar can appear.
enum MenustowBarLocation: Int, CaseIterable, Identifiable {
    /// The menustow Bar will appear in different locations based on context.
    case dynamic = 0

    /// The menustow Bar will appear centered below the mouse pointer.
    case mousePointer = 1

    /// The menustow Bar will appear centered below the menustow icon.
    case menustowIcon = 2

    var id: Int { rawValue }

    /// Localized string key representation.
    var localized: LocalizedStringKey {
        switch self {
        case .dynamic: "Dynamic"
        case .mousePointer: "Mouse pointer"
        case .menustowIcon: "menustow icon"
        }
    }
}
