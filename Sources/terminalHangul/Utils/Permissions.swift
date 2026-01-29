import Cocoa
import CoreGraphics

struct Permissions {

    // MARK: - Input Monitoring

    static func hasInputMonitoringPermission() -> Bool {
        // TODO: Check if Input Monitoring permission is granted
        // This is required for CGEvent.tapCreate to work

        // Try to create a temporary event tap to check permission
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, _, event, _ in
                return Unmanaged.passRetained(event)
            },
            userInfo: nil
        ) else {
            return false
        }

        // Clean up
        CFMachPortInvalidate(eventTap)

        return true
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
                return Unmanaged.passRetained(event)
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
        // TODO: Open System Preferences to Input Monitoring page
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
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
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
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
