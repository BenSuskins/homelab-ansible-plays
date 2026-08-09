import Foundation

/// The two writes that target a workflow. Modelling them as data rather than as
/// closures keeps the typed-throws signature on `perform` unambiguous.
private enum WorkflowWrite {
    case dispatch
    case cancel(runIdentifier: Int)
}

extension AppState {
    /// Triggers fire immediately — no confirmation. The guard against a stray
    /// double-click is that the button is disabled while a run is open, backed
    /// by concurrency groups on the workflows themselves.
    public func trigger(_ workflow: DispatchableWorkflow) async {
        guard canTrigger(workflow) else { return }
        await perform(.dispatch, on: workflow)
    }

    public func cancel(_ workflow: DispatchableWorkflow) async {
        guard canCancel(workflow), let identifier = snapshot.row(for: workflow)?.run?.identifier
        else { return }
        await perform(.cancel(runIdentifier: identifier), on: workflow)
    }

    /// Squash, always: one commit on `main` per pull request, which is one
    /// Update Homelab run, which is one line in the deploy log.
    public func merge(_ pullRequest: PullRequestSummary) async {
        guard pullRequest.canMerge, !busyPullRequests.contains(pullRequest.number) else { return }

        markBusy(pullRequest: pullRequest.number, true)
        defer { markBusy(pullRequest: pullRequest.number, false) }

        do {
            try await client.squashMerge(pullRequestNumber: pullRequest.number)
        } catch {
            setErrorMessage(error.displayMessage)
            return
        }
        // The merge pushes to main, which starts Update Homelab — refresh so the
        // run appears, and re-pace the loop now that something is active.
        await refresh()
        restartPolling()
    }

    private func perform(_ write: WorkflowWrite, on workflow: DispatchableWorkflow) async {
        markBusy(workflow: workflow, true)
        defer { markBusy(workflow: workflow, false) }

        do {
            switch write {
            case .dispatch:
                try await client.dispatch(workflow)
            case .cancel(let runIdentifier):
                try await client.cancelRun(identifier: runIdentifier)
            }
        } catch {
            setErrorMessage(error.displayMessage)
            return
        }

        await refresh()
        restartPolling()
    }
}
