import Cocoa
import CoreGraphics
import IOKit.hid

struct Permissions {

    // MARK: - Input Monitoring

    static func hasInputMonitoringPermission() -> Bool {
        // On macOS 10.15+, use IOHIDCheckAccess to check Input Monitoring permission
        // kIOHIDRequestTypeListenEvent = 1 (for Input Monitoring)
        if #available(macOS 10.15, *) {
            // IOHIDCheckAccess returns true if access is granted
            // kIOHIDRequestTypeListenEvent checks Input Monitoring specifically
            let result = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
            return result == kIOHIDAccessTypeGranted
        } else {
            // On older macOS, fall back to trying to create an event tap
            let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
            guard let eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: eventMask,
                callback: { _, _, event, _ in
                    return Unmanaged.passUnretained(event)
                },
                userInfo: nil
            ) else {
                return false
            }
            CFMachPortInvalidate(eventTap)
            return true
        }
    }

    static func requestInputMonitoringPermission() {
        // TODO: Request Input Monitoring permission
        // On first run, attempting to create an event tap will trigger the system prompt
        // There's no programmatic way to request this - the system shows the dialog

        print("Attempting to trigger Input Monitoring permission dialog...")

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        if let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, _, event, _ in
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        ) {
            CFMachPortInvalidate(eventTap)
            print("Permission already granted")
        } else {
            print("Permission denied or dialog shown")
        }
    }

    static func openInputMonitoringPreferences() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") else {
            print("[Permissions] Failed to create Input Monitoring preferences URL")
            return
        }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Accessibility (Optional)

    static func hasAccessibilityPermission() -> Bool {
        // TODO: Check if Accessibility permission is granted
        // This may be needed for some advanced features

        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func requestAccessibilityPermission() {
        // TODO: Request Accessibility permission with system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilityPreferences() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            print("[Permissions] Failed to create Accessibility preferences URL")
            return
        }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Permission Status

    static func checkAllPermissions() -> PermissionStatus {
        return PermissionStatus(
            inputMonitoring: hasInputMonitoringPermission(),
            accessibility: hasAccessibilityPermission()
        )
    }
}

// MARK: - Permission Status

struct PermissionStatus {
    let inputMonitoring: Bool
    let accessibility: Bool

    var allGranted: Bool {
        return inputMonitoring // Accessibility is optional
    }

    var description: String {
        var parts: [String] = []

        if inputMonitoring {
            parts.append("Input Monitoring: ✓")
        } else {
            parts.append("Input Monitoring: ✗")
        }

        if accessibility {
            parts.append("Accessibility: ✓")
        } else {
            parts.append("Accessibility: ✗ (optional)")
        }

        return parts.joined(separator: ", ")
    }
}
