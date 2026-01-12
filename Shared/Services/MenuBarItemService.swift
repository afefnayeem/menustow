//
//  MenuBarItemService.swift
//  Shared
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import Foundation

enum MenuBarItemService {
    static let name = "com.lswank.menustow.MenuBarItemService"
}

extension MenuBarItemService {
    enum Request: Codable {
        case start
        case sourcePID(WindowInfo)
    }

    enum Response: Codable {
        case start
        case sourcePID(pid_t?)
    }
}
