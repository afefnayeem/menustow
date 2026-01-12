# Learnings

- The source `menustow/Resources/Info.plist` only contains Sparkle keys; bundle/version keys are injected by build settings, so `PlistBuddy` must target the built app’s `Contents/Info.plist` for CFBundle values.
- Permission status now refreshes reliably by combining a timer with `NSApplication.didBecomeActiveNotification`, plus explicit refresh on view appear and on app activation.
- Accessibility permission checks are most reliable when they only gate AX trust; bundling post-event checks into Accessibility can cause false negatives even when the user has granted Accessibility.
- Menu bar item movement on macOS 26 requires explicit post-event access; we split this into a dedicated “Post Events” permission so the UI can prompt and verify it separately.
- Input Monitoring prompts are best triggered by `IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)` + `IOHIDManagerOpen`, with `CGRequestListenEventAccess` as a fallback.
- Acknowledgements can be shown in-app by embedding the bundled PDF in a `PDFView` sheet instead of opening it externally.
- The stonerl/my-build integration introduces the `MenuBarItemService` XPC path and a new `AppState` setup flow; menu bar item loading now depends on that service connection and setup order.
- SwiftLint still runs every build; there is an indentation warning in `menustow/Utilities/Migration.swift` that should be fixed to keep builds clean.
