import Foundation

/// Wire shapes for the two `gh` invocations. These exist only to be decoded and
/// immediately mapped onto domain types, so they stay file-private to the
/// GitHub layer rather than leaking `html_url` upward.
struct WorkflowRunListPayload: Decodable {
    let workflowRuns: [WorkflowRunPayload]

    enum CodingKeys: String, CodingKey {
        case workflowRuns = "workflow_runs"
    }
}

struct WorkflowRunPayload: Decodable {
    let identifier: Int
    let status: String
    let conclusion: String?
    let url: URL
    let startedAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status
        case conclusion
        case url = "html_url"
        case startedAt = "run_started_at"
        case updatedAt = "updated_at"
    }
}

struct PullRequestPayload: Decodable {
    struct Author: Decodable {
        let login: String
    }

    let number: Int
    let title: String
    let author: Author?
    let isDraft: Bool
    let mergeable: String
    let createdAt: Date
    let url: URL
}
