import Foundation
import Testing
@testable import HomelabMenuBarCore

/// The fakes above assert that our code handles `gh` output correctly. These
/// assert that `gh` still *produces* that output — the one thing a fake can
/// never tell us. Strictly read-only: no dispatch, no cancel, no merge.
///
/// Run with: `swift test --filter Contract`
@Suite("Contract (real gh, read-only)", .tags(.contract))
struct ContractTests {
    private var client: GitHubClient {
        GitHubClient(runner: GitHubCommandLineRunner(), repository: .homelab)
    }

    @Test("gh is installed and findable without a shell PATH")
    func executableIsResolvable() throws {
        let located = GitHubCommandLineRunner.locateExecutable()
        try #require(located != nil, "gh not found — install the GitHub CLI")
    }

    @Test("the workflow runs endpoint still has the fields we decode")
    func workflowRunsShapeIsStable() async throws {
        let run = try await client.latestRun(for: .update)

        let found = try #require(run, "Update Homelab has never run on main")
        #expect(found.identifier > 0)
        #expect(found.url.absoluteString.contains("/actions/runs/"))
        #expect(found.startedAt != nil)
    }

    @Test("all three dispatchable workflows still exist in the repository")
    func everyWorkflowResolves() async throws {
        for workflow in DispatchableWorkflow.allCases {
            // A missing workflow file makes `gh api` exit non-zero, which
            // surfaces as a thrown GitHubFailure rather than an empty list.
            _ = try await client.latestRun(for: workflow)
        }
    }

    @Test("gh pr list still emits the JSON fields we ask for")
    func pullRequestShapeIsStable() async throws {
        let pullRequests = try await client.openPullRequests()

        for pullRequest in pullRequests {
            #expect(pullRequest.number > 0)
            #expect(!pullRequest.title.isEmpty)
            #expect(pullRequest.url.absoluteString.contains("/pull/"))
            #expect(!pullRequest.authorLogin.isEmpty)
        }
    }
}

extension Tag {
    @Tag static var contract: Self
}
