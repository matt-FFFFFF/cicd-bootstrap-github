resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  repository         = github_repository.this.name
  use_default        = length(var.oidc_subject_claim_keys) == 0 ? true : false
  include_claim_keys = length(var.oidc_subject_claim_keys) == 0 ? null : var.oidc_subject_claim_keys
}
