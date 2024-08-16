resource "github_branch_protection" "this" {
  count                           = var.branch_protection_enabled ? 1 : 0
  repository_id                   = github_repository.this.name
  pattern                         = "main"
  enforce_admins                  = true
  required_linear_history         = true
  require_conversation_resolution = true
  allows_deletions                = false

  required_status_checks {
    contexts = [for check in var.status_checks : check.context]
    strict   = var.status_checks_strict_policy_enabled
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    restrict_dismissals             = true
    required_approving_review_count = var.approving_review_count
    require_code_owner_reviews      = var.codeowners_enabled
    require_last_push_approval      = var.approving_review_count > 0 ? true : false
    pull_request_bypassers          = var.branch_protection_bypass_actors
  }
  depends_on = [
    github_repository_file.this,
    github_repository_file.codeowners
  ]
}
