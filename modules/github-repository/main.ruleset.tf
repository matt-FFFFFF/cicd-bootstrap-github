resource "github_repository_ruleset" "this" {
  count       = var.ruleset_enabled && data.github_organization.this.plan != local.plan.free || var.repository_visibility != "private" ? 1 : 0
  name        = var.ruleset_name
  enforcement = "active"
  target      = "branch"
  repository  = github_repository.this.name

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = local.ruleset_bypass

    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    deletion                = true # Only allow users with bypass permissions to delete matching refs.
    required_linear_history = true

    pull_request {
      required_approving_review_count   = var.ruleset_approving_review_count
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = var.ruleset_approving_review_count > 0 ? true : false
      require_code_owner_review         = var.codeowners_enabled
      required_review_thread_resolution = true
    }

    dynamic "required_status_checks" {
      for_each = length(var.status_checks) > 0 ? [1] : []

      content {
        strict_required_status_checks_policy = var.status_checks_strict_policy_enabled
        dynamic "required_check" {
          for_each = var.status_checks

          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = data.github_organization.this.plan != local.plan.free || var.repository_visibility == "public"
      error_message = "The GitHub repository ruleset requires a pro or Enterprise plan for private repos."
    }
  }

  depends_on = [
    github_repository_file.this,
    github_repository_file.codeowners,
  ]
}

# Fallback to branch protection if ruleset is not available
resource "github_branch_protection" "this" {
  count                           = var.ruleset_enabled && data.github_organization.this.plan == local.plan.free && var.repository_visibility == "private" ? 1 : 0
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
    required_approving_review_count = length(var.approvers) > 1 ? 1 : 0
    require_code_owner_reviews      = var.codeowners_enabled
    require_last_push_approval      = var.ruleset_approving_review_count > 0 ? true : false
    pull_request_bypassers          = []

  }
  depends_on = [
    github_repository_file.this,
    github_repository_file.codeowners
  ]
}
