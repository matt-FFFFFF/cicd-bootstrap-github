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

run "actor_type_invalid" {
  command = plan

  variables {
    ruleset_bypass = [{
      actor_type  = "user"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.ruleset_bypass
  ]
}

run "team_without_id" {
  command = plan

  variables {
    ruleset_bypass = [{
      actor_type  = "Team"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.ruleset_bypass
  ]
}

run "bypass_mode_invalid" {
  command = plan

  variables {
    ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "never"
      role_name   = "admin"
    }]
  }

  expect_failures = [
    var.ruleset_bypass
  ]
}

run "role_name_invalid" {
  command = plan

  variables {
    ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
      role_name   = "owner"
    }]
  }

  expect_failures = [
    var.ruleset_bypass
  ]
}

run "role_name_null" {
  command = plan

  variables {
    ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.ruleset_bypass
  ]
}

run "correct" {
  command = plan

  variables {
    ruleset_bypass = [
      {
        actor_type  = "RepositoryRole"
        bypass_mode = "always"
        role_name   = "admin"
      },
      {
        actor_type  = "Team"
        bypass_mode = "always",
        actor_id    = 123
      },
      {
        actor_type  = "OrganizationAdmin"
        bypass_mode = "always"
      },
      {
        actor_type  = "Integration"
        bypass_mode = "always",
        actor_id    = 1234
      },
    ]
  }

  assert {
    condition     = local.ruleset_bypass[*].actor_id == [5, 123, 1, 1234]
    error_message = "The actor_id is not set correctly."
  }
}

run "empty_list" {
  command = plan

  variables {
    ruleset_bypass = []
  }
}
