resource "github_team" "this" {
  name        = var.team_name
  description = var.team_description
  privacy     = "closed"
}

resource "github_team_membership" "this" {
  for_each = { for approver in local.approvers : approver => approver }
  team_id  = github_team.this.id
  username = each.key
  role     = "member"
}

resource "github_team_repository" "this" {
  team_id    = github_team.this.id
  repository = github_repository.this.name
  permission = var.team_role
}
