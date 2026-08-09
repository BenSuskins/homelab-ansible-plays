import Foundation
import UserNotifications

public protocol FailureNotifying: Sendable {
    func requestAuthorization() async
    func notify(_ row: RunRow) async
}

/// Success is the expected case and the glyph already reports it, so silence
/// carries meaning: a notification only ever means something broke.
public struct FailureNotifier: FailureNotifying {
    public init() {}

    public func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    public func notify(_ row: RunRow) async {
        let content = UNMutableNotificationContent()
        content.title = "\(row.workflow.displayName) Homelab failed"
        content.body = row.run.map { run in
            let elapsed = run.duration(now: Date()).map(RelativeTime.duration) ?? "—"
            return "Failed after \(elapsed) · click to open the run"
        } ?? "Click to open the run"
        content.sound = .default
        if let url = row.run?.url {
            content.userInfo = ["url": url.absoluteString]
        }

        let request = UNNotificationRequest(
            identifier: "run-failure-\(row.run?.identifier ?? 0)",
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
