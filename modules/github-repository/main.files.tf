resource "github_repository_file" "this" {
  for_each            = var.files
  repository          = github_repository.this.name
  file                = each.key
  content             = each.value.content
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "chore: add ${each.key}"
  overwrite_on_create = true
}

resource "github_repository_file" "codeowners" {
  count               = var.codeowners_enabled ? 1 : 0
  repository          = github_repository.this.name
  file                = ".github/CODEOWNERS"
  content             = <<CONTENT
* @${var.organization_name}/${github_team.this.name}
CONTENT
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "chore: add codeowners"
  overwrite_on_create = true
}
