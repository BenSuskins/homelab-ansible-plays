import Foundation
import Testing
@testable import HomelabMenuBarCore

final class RecordingNotifier: FailureNotifying, @unchecked Sendable {
    private let lock = NSLock()
    private var notified: [RunRow] = []

    var notifiedWorkflows: [DispatchableWorkflow] {
        lock.withLock { notified.map(\.workflow) }
    }

    func requestAuthorization() async {}

    func notify(_ row: RunRow) async {
        lock.withLock { notified.append(row) }
    }
}

@MainActor
@Suite("AppState")
struct AppStateTests {
    private func makeState(
        _ runner: FakeCommandRunner,
        notifier: RecordingNotifier = RecordingNotifier()
    ) -> AppState {
        AppState(
            client: GitHubClient(runner: runner, repository: .homelab),
            repository: .homelab,
            cache: SnapshotCache(fileURL: temporaryCacheURL()),
            notifier: notifier
        )
    }

    private func temporaryCacheURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("homelab-menubar-tests-\(UUID().uuidString)")
            .appendingPathComponent("snapshot.json")
    }

    private func stubHealthyRepository(_ runner: FakeCommandRunner) {
        for workflow in DispatchableWorkflow.allCases {
            runner.stub(
                containing: workflow.fileName,
                json: Samples.workflowRuns(status: "completed", conclusion: "success")
            )
        }
        runner.stub(containing: "pr", json: Samples.pullRequests)
    }

    @Test("shows a full set of rows before the first refresh lands")
    func startsFromPlaceholder() {
        let state = makeState(FakeCommandRunner())

        #expect(state.snapshot.runRows.count == DispatchableWorkflow.allCases.count)
        #expect(state.snapshot.glyph == .ok)
    }

    @Test("populates every row and the pull request list on refresh")
    func refreshPopulatesSnapshot() async {
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner)

        await state.refresh()

        #expect(state.snapshot.row(for: .update)?.status == .succeeded)
        #expect(state.snapshot.pullRequests.count == 2)
        #expect(state.snapshot.lastRefreshedAt != nil)
        #expect(state.snapshot.errorMessage == nil)
    }

    @Test("keeps the last good data on screen when a refresh fails")
    func failedRefreshKeepsLastGoodData() async {
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner)
        await state.refresh()

        let failing = FakeCommandRunner()
        failing.stub(containing: "update.yml", failure: .terminated(exitCode: 1, standardError: "boom"))
        let degraded = AppState(
            client: GitHubClient(runner: failing, repository: .homelab),
            cache: SnapshotCache(fileURL: temporaryCacheURL()),
            notifier: RecordingNotifier()
        )
        degraded.snapshot = state.snapshot

        await degraded.refresh()

        // The error is reported, but the rows survive rather than blanking.
        #expect(degraded.snapshot.errorMessage != nil)
        #expect(degraded.snapshot.row(for: .update)?.status == .succeeded)
    }

    @Test("refuses to trigger a workflow that already has an open run")
    func refusesToTriggerAnOpenWorkflow() async {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "update.yml",
            json: Samples.workflowRuns(status: "in_progress", conclusion: nil)
        )
        runner.stub(containing: "terraform.yml", json: Samples.noWorkflowRuns)
        runner.stub(containing: "clean.yml", json: Samples.noWorkflowRuns)
        runner.stub(containing: "pr", json: "[]")

        let state = makeState(runner)
        await state.refresh()
        let readCount = runner.invocations.count

        await state.trigger(.update)

        // No dispatch was attempted at all — this is the guard that replaces a
        // confirmation dialog.
        #expect(state.canTrigger(.update) == false)
        #expect(runner.invocations.count == readCount)
    }

    @Test("dispatches a workflow whose last run has settled")
    func dispatchesSettledWorkflow() async {
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner)
        await state.refresh()

        await state.trigger(.clean)

        #expect(runner.invokedArguments.contains { arguments in
            arguments.contains("POST")
                && arguments.contains { $0.hasSuffix("clean.yml/dispatches") }
        })
    }

    @Test("notifies once when a workflow turns red")
    func notifiesOnNewFailure() async {
        let notifier = RecordingNotifier()
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner, notifier: notifier)
        await state.refresh()

        let failing = FakeCommandRunner()
        failing.stub(
            containing: "update.yml",
            json: Samples.workflowRuns(identifier: 2002, status: "completed", conclusion: "failure")
        )
        failing.stub(containing: "terraform.yml", json: Samples.noWorkflowRuns)
        failing.stub(containing: "clean.yml", json: Samples.noWorkflowRuns)
        failing.stub(containing: "pr", json: "[]")

        let second = AppState(
            client: GitHubClient(runner: failing, repository: .homelab),
            cache: SnapshotCache(fileURL: temporaryCacheURL()),
            notifier: notifier
        )
        second.snapshot = state.snapshot
        await second.refresh()

        // Notifications are dispatched to a child task; give them a turn.
        try? await Task.sleep(for: .milliseconds(50))

        #expect(second.snapshot.glyph == .failed)
        #expect(notifier.notifiedWorkflows == [.update])
    }

    @Test("will not merge a draft or a conflicting pull request")
    func refusesUnmergeablePullRequests() async {
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner)
        await state.refresh()

        let draft = try! #require(state.snapshot.pullRequests.first { $0.number == 139 })
        let readCount = runner.invocations.count

        await state.merge(draft)

        #expect(runner.invocations.count == readCount)
    }

    @Test("squash merges a ready pull request")
    func mergesReadyPullRequest() async {
        let runner = FakeCommandRunner()
        stubHealthyRepository(runner)
        let state = makeState(runner)
        await state.refresh()

        let ready = try! #require(state.snapshot.pullRequests.first { $0.number == 141 })
        await state.merge(ready)

        #expect(runner.invokedArguments.contains { $0.contains("merge_method=squash") })
    }
}

@Suite("SnapshotCache")
struct SnapshotCacheTests {
    @Test("round-trips a snapshot so the menu paints instantly at launch")
    func roundTripsSnapshot() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("cache-test-\(UUID().uuidString)")
            .appendingPathComponent("snapshot.json")
        let cache = SnapshotCache(fileURL: url)

        let original = MenuSnapshot.make(
            runs: [.update: WorkflowRunSummary(
                identifier: 7,
                status: .failed,
                url: URL(string: "https://github.com/x/y/actions/runs/7")!,
                startedAt: Date(timeIntervalSince1970: 10),
                finishedAt: Date(timeIntervalSince1970: 70)
            )],
            pullRequests: [],
            lastRefreshedAt: Date(timeIntervalSince1970: 100)
        )

        cache.save(original)

        #expect(cache.load() == original)
    }

    @Test("returns nothing rather than throwing when no cache exists")
    func missingCacheIsNotAnError() {
        let cache = SnapshotCache(
            fileURL: URL(fileURLWithPath: "/nonexistent/homelab/snapshot.json")
        )

        #expect(cache.load() == nil)
    }
}
