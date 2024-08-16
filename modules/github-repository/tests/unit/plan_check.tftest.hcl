mock_provider "github" {
  mock_data "github_organization" {
    defaults = {
      plan = "enterprise"
    }
  }
}
mock_provider "modtm" {}

variables {
  organization_name     = "test"
  repository_name       = "test"
  team_name             = "test"
  repository_visibility = "private"
  approvers             = ["test@test.com"]
}

run "private_default_with_approver" {
  command = plan

  assert {
    condition = alltrue([
      can(github_repository.this != null),
      can(github_repository_ruleset.this != null),
      can(github_team.this != null),
      can(github_team_membership.this != null),
      can(github_team_repository.this != null),
    ])
    error_message = "Planned resources are not as expected"
  }
}
