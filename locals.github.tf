locals {
  default_commit_email   = coalesce(local.primary_approver, "demo@microsoft.com")
  github_apply_key       = "apply"
  github_enterprise_plan = "enterprise"
  github_free_plan       = "free"
  github_repositoru_ruleset_bypass_actor_ids = {
    admin              = 5
    write              = 4
    maintain           = 2
    organization_admin = 1
  }
  github_repository_ruleset_bypass = [
    for bypass in var.github_respository_ruleset_bypass : {
      actor_id    = bypass.actor_type == "OrganizationAdmin" ? local.github_repositoru_ruleset_bypass_actor_ids : lookup(local.github_repositoru_ruleset_bypass_actor_ids, bypass.role_name, null)
      actor_type  = bypass.actor_type
      bypass_mode = bypass.bypass_mode
    }
  ]
  primary_approver = length(var.github_approvers) > 0 ? var.github_approvers[0] : ""
}
