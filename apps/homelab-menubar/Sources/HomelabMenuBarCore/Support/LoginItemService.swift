import Foundation
import ServiceManagement

/// What macOS thinks of this app as a login item. `requiresApproval` and
/// `unavailable` are both "off", but for reasons the user can act on, so the
/// menu says which rather than showing an unexplained dead switch.
public enum LoginItemStatus: Equatable, Sendable {
    case enabled
    case disabled
    /// Registered, but switched off by hand in System Settings → Login Items.
    case requiresApproval
    /// macOS cannot resolve the bundle — running the bare SwiftPM executable
    /// rather than `Homelab.app`, typically.
    case unavailable
}

public struct LoginItemFailure: Error, Equatable, Sendable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}

public protocol LoginItemControlling: Sendable {
    func status() -> LoginItemStatus
    func setEnabled(_ enabled: Bool) -> Result<LoginItemStatus, LoginItemFailure>
    /// Only macOS can clear `requiresApproval`, so the menu offers a way there
    /// rather than a switch that refuses to move.
    func openSystemSettings()
}

public struct LoginItemService: LoginItemControlling {
    public init() {}

    public func status() -> LoginItemStatus {
        switch SMAppService.mainApp.status {
        case .enabled: .enabled
        case .requiresApproval: .requiresApproval
        case .notFound: .unavailable
        case .notRegistered: .disabled
        @unknown default: .disabled
        }
    }

    public func setEnabled(_ enabled: Bool) -> Result<LoginItemStatus, LoginItemFailure> {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return .success(status())
        } catch {
            return .failure(LoginItemFailure(message: error.localizedDescription))
        }
    }

    public func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

/// The user's stated intent, which is not the same thing as the system status:
/// `make bundle` ad-hoc signs, so a rebuilt app can arrive with its registration
/// dropped. Remembering what was asked for is what lets the app put it back.
///
/// `@unchecked` only because `UserDefaults` predates `Sendable`; it is
/// documented as thread-safe.
public struct LaunchAtLoginPreference: @unchecked Sendable {
    private static let key = "launchAtLoginRequested"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var isRequested: Bool {
        defaults.bool(forKey: Self.key)
    }

    public func record(_ requested: Bool) {
        defaults.set(requested, forKey: Self.key)
    }
}
