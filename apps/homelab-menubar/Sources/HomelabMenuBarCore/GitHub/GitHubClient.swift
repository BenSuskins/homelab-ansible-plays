import Foundation

public struct GitHubClient: Sendable {
    private let runner: any CommandRunner
    private let repository: RepositoryReference

    public init(runner: any CommandRunner, repository: RepositoryReference = .homelab) {
        self.runner = runner
        self.repository = repository
    }

    // MARK: Reads

    public func latestRun(
        for workflow: DispatchableWorkflow
    ) async throws(GitHubFailure) -> WorkflowRunSummary? {
        let data = try await execute([
            "api",
            "repos/\(repository.slug)/actions/workflows/\(workflow.fileName)/runs"
                + "?per_page=1&branch=\(repository.defaultBranch)",
        ])

        let payload = try decode(WorkflowRunListPayload.self, from: data)
        guard let run = payload.workflowRuns.first else { return nil }

        let status = RunStatus(status: run.status, conclusion: run.conclusion)
        return WorkflowRunSummary(
            identifier: run.identifier,
            status: status,
            url: run.url,
            startedAt: run.startedAt,
            finishedAt: status.isOpen ? nil : run.updatedAt
        )
    }

    public func openPullRequests() async throws(GitHubFailure) -> [PullRequestSummary] {
        let data = try await execute([
            "pr", "list",
            "--repo", repository.slug,
            "--state", "open",
            "--json", "number,title,author,isDraft,mergeable,createdAt,url",
        ])

        let payloads = try decode([PullRequestPayload].self, from: data)
        return payloads.map { payload in
            PullRequestSummary(
                number: payload.number,
                title: payload.title,
                authorLogin: payload.author?.login ?? "ghost",
                isDraft: payload.isDraft,
                readiness: MergeReadiness(mergeableField: payload.mergeable),
                createdAt: payload.createdAt,
                url: payload.url
            )
        }
    }

    // MARK: Writes

    public func dispatch(_ workflow: DispatchableWorkflow) async throws(GitHubFailure) {
        _ = try await execute([
            "api", "--method", "POST",
            "repos/\(repository.slug)/actions/workflows/\(workflow.fileName)/dispatches",
            "-f", "ref=\(repository.defaultBranch)",
        ])
    }

    public func cancelRun(identifier: Int) async throws(GitHubFailure) {
        _ = try await execute([
            "api", "--method", "POST",
            "repos/\(repository.slug)/actions/runs/\(identifier)/cancel",
        ])
    }

    public func squashMerge(pullRequestNumber: Int) async throws(GitHubFailure) {
        _ = try await execute([
            "api", "--method", "PUT",
            "repos/\(repository.slug)/pulls/\(pullRequestNumber)/merge",
            "-f", "merge_method=squash",
        ])
    }

    // MARK: Plumbing

    private func execute(_ arguments: [String]) async throws(GitHubFailure) -> Data {
        do {
            return try await runner.run(arguments)
        } catch {
            throw GitHubFailure(error)
        }
    }

    private func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data
    ) throws(GitHubFailure) -> Value {
        do {
            return try Self.decoder.decode(type, from: data)
        } catch {
            throw GitHubFailure.malformedResponse(String(describing: error))
        }
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
