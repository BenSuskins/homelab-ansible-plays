import Foundation
import Observation

@MainActor
@Observable
public final class AppState {
    public internal(set) var snapshot: MenuSnapshot
    public internal(set) var isRefreshing = false
    /// Workflows and pull requests with an in-flight write, so their button can
    /// show a spinner and refuse a second click before the next poll lands.
    public internal(set) var busyWorkflows: Set<DispatchableWorkflow> = []
    public internal(set) var busyPullRequests: Set<Int> = []

    public let repository: RepositoryReference

    let client: GitHubClient
    let cache: SnapshotCache
    let notifier: any FailureNotifying
    var pollingTask: Task<Void, Never>?

    public init(
        client: GitHubClient,
        repository: RepositoryReference = .homelab,
        cache: SnapshotCache = SnapshotCache(),
        notifier: any FailureNotifying = FailureNotifier()
    ) {
        self.client = client
        self.repository = repository
        self.cache = cache
        self.notifier = notifier
        self.snapshot = cache.load() ?? .placeholder
    }

    public var quickLinks: [QuickLink] {
        QuickLink.standard(for: repository)
    }

    public func canTrigger(_ workflow: DispatchableWorkflow) -> Bool {
        guard !busyWorkflows.contains(workflow) else { return false }
        return snapshot.row(for: workflow)?.canTrigger ?? false
    }

    public func canCancel(_ workflow: DispatchableWorkflow) -> Bool {
        guard !busyWorkflows.contains(workflow) else { return false }
        return snapshot.row(for: workflow)?.canCancel ?? false
    }

    public func isBusy(pullRequest number: Int) -> Bool {
        busyPullRequests.contains(number)
    }

    func markBusy(workflow: DispatchableWorkflow, _ busy: Bool) {
        if busy {
            busyWorkflows.insert(workflow)
        } else {
            busyWorkflows.remove(workflow)
        }
    }

    func markBusy(pullRequest number: Int, _ busy: Bool) {
        if busy {
            busyPullRequests.insert(number)
        } else {
            busyPullRequests.remove(number)
        }
    }

    func setErrorMessage(_ message: String?) {
        var updated = snapshot
        updated.errorMessage = message
        snapshot = updated
    }
}
