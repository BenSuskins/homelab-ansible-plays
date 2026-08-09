import Foundation

public enum GitHubFailure: Error, Equatable, Sendable {
    case commandLineToolMissing
    case notAuthenticated
    case commandFailed(exitCode: Int32, message: String)
    case malformedResponse(String)

    init(_ failure: CommandFailure) {
        switch failure {
        case .executableNotFound:
            self = .commandLineToolMissing
        case .terminated(let exitCode, let standardError):
            // `gh` exits 4 when the stored credentials are missing or expired.
            if exitCode == 4 || standardError.localizedCaseInsensitiveContains("gh auth login") {
                self = .notAuthenticated
            } else {
                self = .commandFailed(exitCode: exitCode, message: standardError)
            }
        }
    }

    public var displayMessage: String {
        switch self {
        case .commandLineToolMissing:
            "`gh` not found — install the GitHub CLI"
        case .notAuthenticated:
            "Not signed in — run `gh auth login`"
        case .commandFailed(_, let message):
            message.isEmpty ? "GitHub command failed" : message
        case .malformedResponse:
            "Unexpected response from `gh`"
        }
    }
}
