import Foundation

public enum CommandFailure: Error, Equatable, Sendable {
    case executableNotFound(String)
    case terminated(exitCode: Int32, standardError: String)
}

/// The single seam between this app and the outside world. Everything the app
/// knows about GitHub arrives as bytes from a `gh` invocation, so faking this
/// protocol fakes the entire network.
public protocol CommandRunner: Sendable {
    func run(_ arguments: [String]) async throws(CommandFailure) -> Data
}

public struct GitHubCommandLineRunner: CommandRunner {
    private let executableURL: URL?

    public init(executableURL: URL? = nil) {
        self.executableURL = executableURL ?? Self.locateExecutable()
    }

    /// A GUI app inherits a minimal `PATH` that omits Homebrew and Nix, so the
    /// usual `/usr/bin/env gh` trick finds nothing once the app is launched
    /// from Finder rather than a shell.
    static func locateExecutable() -> URL? {
        let pathDirectories = (ProcessInfo.processInfo.environment["PATH"] ?? "")
            .split(separator: ":")
            .map(String.init)

        let fallbackDirectories = [
            "\(NSHomeDirectory())/.nix-profile/bin",
            "/run/current-system/sw/bin",
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
        ]

        let fileManager = FileManager.default
        for directory in pathDirectories + fallbackDirectories {
            let candidate = URL(fileURLWithPath: directory).appendingPathComponent("gh")
            if fileManager.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }
        return nil
    }

    public func run(_ arguments: [String]) async throws(CommandFailure) -> Data {
        guard let executableURL else {
            throw .executableNotFound("gh")
        }

        let outcome = await Task.detached(priority: .utility) {
            Self.invoke(executableURL: executableURL, arguments: arguments)
        }.value

        switch outcome {
        case .success(let data):
            return data
        case .failure(let failure):
            throw failure
        }
    }

    private static func invoke(
        executableURL: URL,
        arguments: [String]
    ) -> Result<Data, CommandFailure> {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        // `gh` reads its own config, so it needs a HOME; it does not need a PATH.
        var environment = ProcessInfo.processInfo.environment
        environment["HOME"] = NSHomeDirectory()
        environment["GH_PROMPT_DISABLED"] = "1"
        environment["NO_COLOR"] = "1"
        process.environment = environment

        let standardOutput = Pipe()
        let standardError = Pipe()
        process.standardOutput = standardOutput
        process.standardError = standardError

        do {
            try process.run()
        } catch {
            return .failure(.executableNotFound(executableURL.path))
        }

        // Drain both pipes before waiting: a process that fills the 64KB pipe
        // buffer blocks forever if we wait first and read second.
        let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let message = String(decoding: errorData, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return .failure(.terminated(exitCode: process.terminationStatus, standardError: message))
        }

        return .success(outputData)
    }
}
