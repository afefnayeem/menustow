//
//  Permission.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import Combine
import Cocoa
import CoreGraphics
import IOKit.hid

// MARK: - Permission

/// An object that encapsulates the behavior of checking for and requesting
/// a specific permission for the app.
@MainActor
class Permission: ObservableObject, Identifiable {
    /// A Boolean value that indicates whether the app has this permission.
    @Published private(set) var hasPermission = false

    /// The title of the permission.
    let title: String

    /// Descriptive details for the permission.
    let details: [String]

    /// A Boolean value that indicates if the app can work without this permission.
    let isRequired: Bool

    /// The URL of the settings pane to open.
    private let settingsURL: URL?

    /// The function that checks permissions.
    private let check: () -> Bool

    /// The function that requests permissions.
    private let request: () -> Void

    /// Observer that runs on a timer to check permissions.
    private var timerCancellable: AnyCancellable?

    /// Observer that observes the ``hasPermission`` property.
    private var hasPermissionCancellable: AnyCancellable?

    /// Creates a permission.
    ///
    /// - Parameters:
    ///   - title: The title of the permission.
    ///   - details: Descriptive details for the permission.
    ///   - isRequired: A Boolean value that indicates if the app can work without this permission.
    ///   - settingsURL: The URL of the settings pane to open.
    ///   - check: A function that checks permissions.
    ///   - request: A function that requests permissions.
    init(
        title: String,
        details: [String],
        isRequired: Bool,
        settingsURL: URL?,
        check: @escaping () -> Bool,
        request: @escaping () -> Void
    ) {
        self.title = title
        self.details = details
        self.isRequired = isRequired
        self.settingsURL = settingsURL
        self.check = check
        self.request = request
        self.hasPermission = check()
        configureCancellables()
    }

    /// Sets up the internal observers for the permission.
    private func configureCancellables() {
        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in () }

        let appDidBecomeActive = NotificationCenter.default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .map { _ in () }

        timerCancellable = Publishers.Merge(timer, appDidBecomeActive)
            .merge(with: Just(()))
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                hasPermission = check()
            }
    }

    /// Performs the request and opens the System Settings app to the appropriate pane.
    func performRequest() {
        guard !hasPermission else {
            return
        }
        request()
        if let settingsURL {
            NSWorkspace.shared.open(settingsURL)
        }
    }

    /// Forces an immediate permission check.
    func refresh() {
        hasPermission = check()
    }

    /// Asynchronously waits for the app to be granted this permission.
    func waitForPermission() async {
        configureCancellables()
        guard !hasPermission else {
            return
        }
        return await withCheckedContinuation { continuation in
            hasPermissionCancellable = $hasPermission.sink { [weak self] hasPermission in
                guard let self else {
                    continuation.resume()
                    return
                }
                if hasPermission {
                    hasPermissionCancellable?.cancel()
                    continuation.resume()
                }
            }
        }
    }

    /// Stops running the permission check.
    func stopCheck() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hasPermissionCancellable?.cancel()
        hasPermissionCancellable = nil
    }
}

// MARK: - AccessibilityPermission

final class AccessibilityPermission: Permission {
    init() {
        super.init(
            title: "Accessibility",
            details: [
                "Get real-time information about the menu bar.",
                "Arrange menu bar items.",
            ],
            isRequired: true,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"),
            check: {
                return AXHelpers.isProcessTrusted()
            },
            request: {
                AXHelpers.isProcessTrusted(prompt: true)
                NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
            }
        )
    }
}

// MARK: - InputMonitoringPermission

final class InputMonitoringPermission: Permission {
    init() {
        super.init(
            title: "Input Monitoring",
            details: [
                "Detect command-dragging menu bar items.",
                "Enable global menu bar interaction handling.",
            ],
            isRequired: true,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"),
            check: {
                if #available(macOS 10.15, *) {
                    let access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
                    if access == kIOHIDAccessTypeGranted {
                        return true
                    }
                    if access == kIOHIDAccessTypeUnknown {
                        return CGPreflightListenEventAccess()
                    }
                    return false
                }
                return true
            },
            request: {
                if #available(macOS 10.15, *) {
                    _ = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
                    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
                    IOHIDManagerSetDeviceMatching(manager, nil)
                    IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
                    _ = CGRequestListenEventAccess()
                }
                NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
            }
        )
    }
}

// MARK: - PostEventsPermission

final class PostEventsPermission: Permission {
    init() {
        super.init(
            title: "Post Events",
            details: [
                "Move menu bar items.",
                "Trigger menu bar actions programmatically.",
            ],
            isRequired: true,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"),
            check: {
                if #available(macOS 10.15, *) {
                    let access = IOHIDCheckAccess(kIOHIDRequestTypePostEvent)
                    if access == kIOHIDAccessTypeGranted {
                        return true
                    }
                    if access == kIOHIDAccessTypeUnknown {
                        return CGPreflightPostEventAccess()
                    }
                    return false
                }
                return true
            },
            request: {
                if #available(macOS 10.15, *) {
                    _ = IOHIDRequestAccess(kIOHIDRequestTypePostEvent)
                    _ = CGRequestPostEventAccess()
                }
                NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
            }
        )
    }
}

// MARK: - ScreenRecordingPermission

final class ScreenRecordingPermission: Permission {
    init() {
        super.init(
            title: "Screen Recording",
            details: [
                "Change the menu bar's appearance.",
                "Display images of individual menu bar items.",
            ],
            isRequired: false,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"),
            check: {
                ScreenCapture.checkPermissions()
            },
            request: {
                ScreenCapture.requestPermissions()
            }
        )
    }
}
