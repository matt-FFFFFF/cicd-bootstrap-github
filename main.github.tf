data "github_organization" "this" {
  name = var.github_organization_name
}

resource "github_repository" "this" {
  name                        = var.github_repository_name
  description                 = var.github_repository_description
  auto_init                   = true
  visibility                  = data.github_organization.this.plan == local.github_free_plan ? "public" : "private"
  allow_update_branch         = true
  allow_merge_commit          = false
  allow_rebase_merge          = true
  allow_squash_merge          = true
  vulnerability_alerts        = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  delete_branch_on_merge      = true
}

resource "github_repository_ruleset" "this" {
  count       = var.github_repository_ruleset_enabled ? 1 : 0
  name        = github_repository_ruleset_name
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
    for_each = local.github_repository_ruleset_bypass

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
      required_approving_review_count = var.github_repository_ruleset_approving_review_count
      dismiss_stale_reviews_on_push   = true
      require_last_push_approval      = var.github_repository_ruleset_approving_review_count > 0 ? true : false
    }

    required_status_checks {
      required_check {
        context = "TODO"
      }
    }
  }
}

resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  repository         = github_repository.this.name
  use_default        = false
  include_claim_keys = ["repository", "environment", "job_workflow_ref"]
}
