provider "github" {
  owner = var.organization_name
}

run "setup_tests" {
  module {
    source = "./tests/integration/modules/naming"
  }
}

run "apply" {
  variables {
    repository_name           = run.setup_tests.repository_name
    team_name                 = "team-${run.setup_tests.repository_name}"
    branch_protection_enabled = true
    ruleset_enabled           = false
  }
  command = apply
}

run "check_codeowners" {
  module {
    source = "./tests/integration/modules/checkfile"
  }

  variables {
    file_path       = ".github/CODEOWNERS"
    repository_name = run.setup_tests.repository_name
    branch_name     = "main"
  }

  assert {
    error_message = "CODEOWNERS file not correct"
    condition     = output.content == <<EOF
* @${var.organization_name}/team-${run.setup_tests.repository_name}
EOF
  }
}
