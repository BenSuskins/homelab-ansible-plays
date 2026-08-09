import HomelabMenuBarCore
import SwiftUI

@main
struct HomelabMenuBarApp: App {
    @State private var state = AppState(client: GitHubClient(runner: GitHubCommandLineRunner()))

    var body: some Scene {
        MenuBarExtra {
            MenuView()
                .environment(state)
        } label: {
            Image(systemName: state.snapshot.glyph.symbolName)
                .symbolRenderingMode(state.snapshot.glyph == .failed ? .multicolor : .monochrome)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: scenePhaseHasStarted, initial: true) { _, _ in
            state.start()
        }
    }

    /// `MenuBarExtra` has no scene phase of its own; this exists purely to give
    /// `onChange(initial:)` something to fire against exactly once at launch.
    private var scenePhaseHasStarted: Bool { true }
}
