provider "github" {
  owner = var.organization_name
}

variables {
  organization_name     = "microsoft-avm-end-to-end-tests"
  repository_visibility = "public"
  codeowners_enabled    = false
}

run "setup_tests" {
  module {
    source = "./tests/integration/setup/naming"
  }
}

run "apply" {
  variables {
    repository_name = run.setup_tests.repository_name
    team_name       = "team-${run.setup_tests.repository_name}"
  }
  command = apply
}
