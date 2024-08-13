mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "github" {}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  github_organization_name = "test"
  github_repository_name   = "test"
}

run "actor_type_invalid" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [{
      actor_type  = "user"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.github_respository_ruleset_bypass
  ]
}

run "team_without_id" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [{
      actor_type  = "Team"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.github_respository_ruleset_bypass
  ]
}

run "bypass_mode_invalid" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "never"
      role_name   = "admin"
    }]
  }

  expect_failures = [
    var.github_respository_ruleset_bypass
  ]
}

run "role_name_invalid" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
      role_name   = "owner"
    }]
  }

  expect_failures = [
    var.github_respository_ruleset_bypass
  ]
}

run "role_name_null" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [{
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    }]
  }

  expect_failures = [
    var.github_respository_ruleset_bypass
  ]
}

run "correct" {
  command = plan

  variables {
    github_respository_ruleset_bypass = [
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
}

run "empty_list" {
  command = plan

  variables {
    github_respository_ruleset_bypass = []
  }
}
