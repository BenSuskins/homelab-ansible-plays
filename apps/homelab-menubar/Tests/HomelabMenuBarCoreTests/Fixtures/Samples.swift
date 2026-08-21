import Foundation

/// Trimmed but otherwise verbatim `gh` output. Field names and value shapes
/// match the real API so the decoding under test is the decoding that ships.
enum Samples {
    static func workflowRuns(
        identifier: Int = 1001,
        status: String,
        conclusion: String?
    ) -> String {
        let conclusionField = conclusion.map { "\"\($0)\"" } ?? "null"
        return """
        {
          "total_count": 1,
          "workflow_runs": [
            {
              "id": \(identifier),
              "name": "Update Homelab",
              "head_branch": "main",
              "status": "\(status)",
              "conclusion": \(conclusionField),
              "html_url": "https://github.com/BenSuskins/homelab/actions/runs/\(identifier)",
              "run_started_at": "2026-08-09T10:00:00Z",
              "updated_at": "2026-08-09T10:04:01Z"
            }
          ]
        }
        """
    }

    static let noWorkflowRuns = """
    { "total_count": 0, "workflow_runs": [] }
    """

    static let pullRequests = """
    [
      {
        "number": 141,
        "title": "chore(deps): update ansible docker images (major)",
        "author": { "login": "app/renovate" },
        "isDraft": false,
        "mergeable": "MERGEABLE",
        "createdAt": "2026-08-06T09:15:00Z",
        "url": "https://github.com/BenSuskins/homelab/pull/141"
      },
      {
        "number": 139,
        "title": "Add Faro frontend observability",
        "author": null,
        "isDraft": true,
        "mergeable": "CONFLICTING",
        "createdAt": "2026-08-01T09:15:00Z",
        "url": "https://github.com/BenSuskins/homelab/pull/139"
      }
    ]
    """
}
