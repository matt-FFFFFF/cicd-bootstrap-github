resource "github_repository_environment" "this" {
  depends_on  = [github_team_repository.this]
  for_each    = var.environments
  environment = each.value
  repository  = github_repository.this.name

  dynamic "reviewers" {
    for_each = each.value.review_required && length(var.approvers) > 0 ? [1] : []
    content {
      teams = [
        github_team.this.id
      ]
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.protected_branches_only ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}

resource "github_actions_environment_variable" "this" {
  for_each      = local.environments_variables
  environment   = each.value.environment
  repository    = github_repository.this.name
  variable_name = each.value.key
  value         = each.value.value
}

resource "github_actions_environment_secret" "this" {
  for_each        = local.environments_secrets
  environment     = each.value.environment
  repository      = github_repository.this.name
  secret_name     = each.value.key
  plaintext_value = var.environments_secrets_values[each.value.key]
}
