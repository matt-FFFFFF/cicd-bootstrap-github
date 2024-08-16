output "issuer" {
  value = "https://token.actions.githubusercontent.com"
}

output "organization_plan" {
  value = data.github_organization.this.plan
}

output "organization_url" {
  value = local.organization_url
}

output "organization_users" {
  value = data.github_organization.this.users
}

output "repository_name" {
  value = github_repository.this.name
}

output "runner_group_name" {
  value = try(github_actions_runner_group.this[0].name, null)
}

output "oidc_subjects" {
  value = local.oidc_subjects
}
