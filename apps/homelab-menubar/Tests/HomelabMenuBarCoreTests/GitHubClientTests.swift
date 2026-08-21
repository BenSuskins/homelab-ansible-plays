import Foundation
import Testing
@testable import HomelabMenuBarCore

@Suite("GitHubClient")
struct GitHubClientTests {
    private func client(_ runner: FakeCommandRunner) -> GitHubClient {
        GitHubClient(runner: runner, repository: .homelab)
    }

    @Test("decodes a completed successful run")
    func decodesSuccessfulRun() async throws {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "update.yml",
            json: Samples.workflowRuns(status: "completed", conclusion: "success")
        )

        let run = try await client(runner).latestRun(for: .update)

        #expect(run?.status == .succeeded)
        #expect(run?.identifier == 1001)
        #expect(run?.finishedAt != nil)
    }

    @Test("maps GitHub's waiting status onto awaiting approval")
    func mapsWaitingStatus() async throws {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "terraform.yml",
            json: Samples.workflowRuns(status: "waiting", conclusion: nil)
        )

        let run = try await client(runner).latestRun(for: .terraform)

        #expect(run?.status == .awaitingApproval)
        // An unfinished run has no end, even though GitHub keeps stamping updated_at.
        #expect(run?.finishedAt == nil)
    }

    @Test(
        "maps every conclusion the API can return",
        arguments: [
            ("completed", "success", RunStatus.succeeded),
            ("completed", "failure", RunStatus.failed),
            ("completed", "timed_out", RunStatus.failed),
            ("completed", "startup_failure", RunStatus.failed),
            ("completed", "cancelled", RunStatus.cancelled),
            ("completed", "skipped", RunStatus.succeeded),
            ("in_progress", nil, RunStatus.running),
            ("queued", nil, RunStatus.queued),
            ("requested", nil, RunStatus.queued),
        ]
    )
    func mapsConclusions(status: String, conclusion: String?, expected: RunStatus) async throws {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "update.yml",
            json: Samples.workflowRuns(status: status, conclusion: conclusion)
        )

        let run = try await client(runner).latestRun(for: .update)

        #expect(run?.status == expected)
    }

    @Test("a workflow that never ran yields no run")
    func handlesNeverRun() async throws {
        let runner = FakeCommandRunner()
        runner.stub(containing: "clean.yml", json: Samples.noWorkflowRuns)

        let run = try await client(runner).latestRun(for: .clean)

        #expect(run == nil)
    }

    @Test("asks only for the latest run on the default branch")
    func queriesLatestRunOnDefaultBranch() async throws {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "update.yml",
            json: Samples.workflowRuns(status: "completed", conclusion: "success")
        )

        _ = try await client(runner).latestRun(for: .update)

        let arguments = try #require(runner.invokedArguments.first)
        #expect(arguments.contains { $0.contains("per_page=1") })
        #expect(arguments.contains { $0.contains("branch=main") })
    }

    @Test("decodes pull requests including a null author and a draft")
    func decodesPullRequests() async throws {
        let runner = FakeCommandRunner()
        runner.stub(containing: "pr", json: Samples.pullRequests)

        let pullRequests = try await client(runner).openPullRequests()

        #expect(pullRequests.count == 2)
        #expect(pullRequests[0].number == 141)
        #expect(pullRequests[0].authorLogin == "app/renovate")
        #expect(pullRequests[0].readiness == .mergeable)
        #expect(pullRequests[0].canMerge)

        // A null author decodes rather than throwing, and a conflicting draft
        // must never offer a merge button.
        #expect(pullRequests[1].authorLogin == "ghost")
        #expect(pullRequests[1].readiness == .conflicting)
        #expect(pullRequests[1].canMerge == false)
    }

    @Test("dispatches against the default branch")
    func dispatchesWorkflow() async throws {
        let runner = FakeCommandRunner()

        try await client(runner).dispatch(.clean)

        let arguments = try #require(runner.invokedArguments.first)
        #expect(arguments.contains("POST"))
        #expect(arguments.contains("repos/BenSuskins/homelab/actions/workflows/clean.yml/dispatches"))
        #expect(arguments.contains("ref=main"))
    }

    @Test("merges by squashing")
    func squashMerges() async throws {
        let runner = FakeCommandRunner()

        try await client(runner).squashMerge(pullRequestNumber: 141)

        let arguments = try #require(runner.invokedArguments.first)
        #expect(arguments.contains("PUT"))
        #expect(arguments.contains("merge_method=squash"))
        #expect(arguments.contains("repos/BenSuskins/homelab/pulls/141/merge"))
    }

    @Test("reports a missing gh binary as a distinct failure")
    func reportsMissingExecutable() async throws {
        let runner = FakeCommandRunner()
        runner.stub(containing: "update.yml", failure: .executableNotFound("gh"))

        await #expect(throws: GitHubFailure.commandLineToolMissing) {
            try await client(runner).latestRun(for: .update)
        }
    }

    @Test("recognises an expired login rather than reporting a generic failure")
    func recognisesLoggedOutState() async throws {
        let runner = FakeCommandRunner()
        runner.stub(
            containing: "update.yml",
            failure: .terminated(exitCode: 4, standardError: "gh auth login required")
        )

        await #expect(throws: GitHubFailure.notAuthenticated) {
            try await client(runner).latestRun(for: .update)
        }
    }

    @Test("surfaces unparseable output instead of crashing")
    func surfacesMalformedOutput() async throws {
        let runner = FakeCommandRunner()
        runner.stub(containing: "update.yml", json: "not json at all")

        await #expect(throws: GitHubFailure.self) {
            try await client(runner).latestRun(for: .update)
        }
    }
}
