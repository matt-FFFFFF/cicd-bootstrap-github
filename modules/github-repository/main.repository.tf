resource "github_repository" "this" {
  name                        = var.repository_name
  description                 = var.repository_description
  auto_init                   = true
  visibility                  = var.visibility
  allow_update_branch         = true
  allow_merge_commit          = false
  allow_rebase_merge          = true
  allow_squash_merge          = true
  vulnerability_alerts        = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  delete_branch_on_merge      = true
}

resource "github_actions_repository_access_level" "this" {
  count        = var.visibility != "private" ? 1 : 0
  access_level = var.access_level
  repository   = github_repository.this.name
}
