provider "github" {
  owner = var.organization_name
}
mock_provider "modtm" {}

variables {
  repository_name   = "test123123f"
  team_name         = "test123123f"
  organization_name = "microsoft-avm-end-to-end-tests"
  visibility        = "public"
}

run "default" {
  command = apply
}
