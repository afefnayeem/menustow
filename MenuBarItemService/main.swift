//
//  main.swift
//  MenuBarItemService
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import Foundation

SourcePIDCache.shared.start()
Listener.shared.activate()
RunLoop.current.run()
